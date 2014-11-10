-module(koordinator).
-export([start/0]).

start() -> 
	% Config-Krams
	{ok, ConfigListe} = file:consult("koordinator.cfg"),
	{ok, NameserviceNode} = util:get_config_value(nameservicenode, ConfigListe),
	{ok, NameserviceName} = util:get_config_value(nameservicename, ConfigListe),
	{ok, KoordinatorName} = util:get_config_value(koordinatorname, ConfigListe),
	{ok, Arbeitszeit} = util:get_config_value(arbeitszeit, ConfigListe),
	{ok, Wartezeit} = util:get_config_value(termzeit, ConfigListe),
	{ok, GGTProzessAnzahl} = util:get_config_value(ggtprozessnummer, ConfigListe),
	{ok, KorrigierenFlag} = util:get_config_value(korrigieren, ConfigListe),
	LogFile = atom_to_list(KoordinatorName) ++ ".log",
	
	% Warte darauf, dass der Nameservice verfuegbar ist
	util:wait_for_nameservice(NameserviceNode),
	
  	% Ermittle die PID des Nameservice
	Nameservice = global:whereis_name(NameserviceName),

	% Versuche den eigenen Namen beim Nameservice zu binden
	case util:bind_name(Nameservice, KoordinatorName, NameserviceNode) of
		ok -> 
			util:logging(LogFile, "Name " ++ atom_to_list(KoordinatorName) ++ " erfolgreich registriert\n");
		in_use -> 
			util:logging(LogFile, "Name " ++ atom_to_list(KoordinatorName) ++ " schon in benutzung - Beende Prozess\n"),
			erlang:fault("Name bereits vergeben\n")
	end,

	initialize_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, [], LogFile).

% Startphase
initialize_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile) ->
	receive 
		{getsteeringval, PID} ->
			util:logging(LogFile, "Starter " ++ pid_to_list(PID) ++ " Angemeldet\n"),
			PID ! {steeringval, Arbeitszeit, Wartezeit, GGTProzessAnzahl},
			initialize_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile);

		{hello, ClientName} ->
			util:logging(LogFile, "GGT-Prozess " ++ atom_to_list(ClientName) ++ " Angemeldet\n"),
			initialize_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, [ClientName | ClientList], LogFile);

		{step, PID} ->
			util:logging(LogFile, "Wechsle in Arbeitsphase\n"),
			PID ! ok,
			ShuffeledClientList = util:shuffle(ClientList),
			inform_all_about_neighbors(ShuffeledClientList, Nameservice),
			working_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile, -1);
		
		Message ->
			util:logging(LogFile, "Unbekannte / unerwartete Nachricht erhalten\n"),
			initialize_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile)
	end.

% Arbeitsphase
working_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile, Result) ->
	receive
		{kill, PID} ->
			util:logging(LogFile, "System wird heruntergefahren\n"),
			PID ! ok,
			ending_loop(ClientList, Nameservice, LogFile);

		{reset, PID} -> 
			util:logging(LogFile, "Resette Clients\n"),
			kill_all_GGTs(ClientList, Nameservice),
			PID ! ok,
			initialize_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, [], LogFile);

		{toggle, PID} ->
			util:logging(LogFile, "KorrigierenFlag: " ++ util:toggle_boolean(KorrigierenFlag) ++ "\n"),
			PID ! ok,
			working_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, util:toggle_boolean(KorrigierenFlag), ClientList, LogFile, Result);

		{nudge, PID} ->
			util:logging(LogFile, "Gesundheitszustand der ggT-Prozesse\n"),
			StatusList = ping_all_clients(Nameservice, KoordinatorName, Arbeitszeit, ClientList, LogFile),
			util:logging(LogFile, util:list_to_list(StatusList)),
			PID ! ok,
			working_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile, Result);

		{prompt, PID} ->
			util:logging(LogFile, "Mi der antwortenden ggT-Prozesse\n"),
			MiList = value_of_all_clients(Nameservice, KoordinatorName, Arbeitszeit, ClientList, LogFile),
			util:logging(LogFile, util:list_to_list(MiList)),
			PID ! ok,
			working_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile, Result);

		{calc, WggT, PID} ->
			util:logging(LogFile, "Starte Berechnung mit Wunsch-GGT " ++ integer_to_list(WggT) ++"\n"),
			MiniMis = util:bestimme_mis(WggT, calc_num(length(ClientList))),
			Mis = util:bestimme_mis(WggT, length(ClientList)),
			send_mis(Mis, ClientList, Nameservice, LogFile),
			start_some(MiniMis, ClientList, Nameservice, LogFile),
			PID ! ok,
			working_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile, WggT);

		{briefmi, {ClientName, Mi, Timestamp}} ->
			util:logging(LogFile, atom_to_list(ClientName) ++ " hat das neue Mi " ++ integer_to_list(Mi) ++ " | " ++ Timestamp ++ "\n"),
			working_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile, Result);
		
		{briefterm, {Clientname, Mi, Timestamp}, From} ->
			case Mi > Result of
				false ->
					util:logging(LogFile, "Das korrekte Ergebnis " ++ integer_to_list(Mi) ++ "wurde von " ++ atom_to_list(Clientname) ++ "um " ++ Timestamp ++ "gefunden\n"),
					working_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile, Result);
				true ->
					case KorrigierenFlag  == true of
						false ->
							util:logging(LogFile, "Das falsche Ergebnis " ++ integer_to_list(Mi) ++ "wurde von " ++ atom_to_list(Clientname) ++ "um " ++ Timestamp ++ "gefunden\n"),
							working_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile, Result);
						true ->
							util:send_message_to({sendy, Result}, From, Nameservice),
							util:logging(LogFile, "Das falsche Ergebnis " ++ integer_to_list(Mi) ++ "wurde von " ++ atom_to_list(Clientname) ++ "um " ++ Timestamp ++ "gefunden. Korrektur versandt\n")
					end
			end;

		Message ->
			util:logging(LogFile, "Unbekannte / unerwartete Nachricht erhalten\n"),
			working_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile, Result)
	end.
		


% Beendigungsphase
ending_loop(ClientList, Nameservice, LogFile) ->
	kill_all_GGTs(ClientList, Nameservice),
	ok.


% Hilfsmethoden
inform_all_about_neighbors(ClientList, Nameservice) ->
	inform_all_about_neighbors_helper(ClientList, ClientList, Nameservice).

inform_all_about_neighbors_helper([Head | Tail1], [Head | Tail2], Nameservice) ->
	util:send_message_to({setneighbors, util:last(Tail2), util:head(Tail2)}, Head, Nameservice),
	inform_all_about_neighbors_helper(Tail1, [Head | Tail2], Nameservice);

inform_all_about_neighbors_helper([Head | []], ClientList, Nameservice) ->
	util:send_message_to({setneighbors, util:element_before(Head, ClientList), util:head(ClientList)}, Head, Nameservice);

inform_all_about_neighbors_helper([Head | Tail], ClientList, Nameservice) ->
	util:send_message_to({setneighbors, util:element_before(Head, ClientList), util:element_after(Head, ClientList)}, Head, Nameservice),
	inform_all_about_neighbors_helper(Tail, ClientList, Nameservice).


kill_all_GGTs([], _) ->
	ok;

kill_all_GGTs([Head | Tail], Nameservice) ->
	util:send_message_to(kill, Head, Nameservice),
	kill_all_GGTs(Tail, Nameservice).


ping_all_clients(Nameservice, KoordinatorName, Arbeitszeit, ClientList, LogFile) ->
	util:message_to_all({pingGGT, KoordinatorName}, ClientList, Nameservice),
	StatusList = util:list_with_size(length(ClientList), timeout),
	ping_all_clients_helper(Nameservice, Arbeitszeit, ClientList, StatusList, LogFile).

ping_all_clients_helper(Nameservice, Arbeitszeit, ClientList, StatusList, LogFile) ->
	receive
		{pongGGT, From} ->
			Index = util:index_of(From, ClientList),
			NewStatusList = util:replace_index_with(Index, alive, StatusList),
			ping_all_clients_helper(Nameservice, Arbeitszeit, ClientList, NewStatusList, LogFile)
	after 
		Arbeitszeit * 5 ->
			StatusList
	end.


value_of_all_clients(Nameservice, KoordinatorName, Arbeitszeit, ClientList, LogFile) ->
	util:message_to_all({tellmi, KoordinatorName}, ClientList, Nameservice),
	value_of_all_clients_helper([], Arbeitszeit, LogFile).

value_of_all_clients_helper(RespondList, Arbeitszeit, LogFile) ->
	receive 
		{mi, Mi} ->
			value_of_all_clients_helper([Mi | RespondList], Arbeitszeit, LogFile)
	after
		Arbeitszeit * 5 ->
			RespondList
	end.


send_mis(_, [], _, _) ->
	ok;

send_mis([Mi | Mis], [Client | ClientList], Nameservice, LogFile) ->
	util:send_message_to({setpm, Mi}, Client, Nameservice),
	send_mis(Mis, ClientList, Nameservice, LogFile).


calc_num(Num) ->
	case (Num * 0.15) < 2 of
		true -> 2;
		false -> round(Num * 0.15)
	end.


start_some([], _, _, _) ->
	ok;

start_some([Mi | MiniMis], [Client | ClientList], Nameservice, LogFile) ->
	util:send_message_to({sendy, Mi}, Client, Nameservice),
	start_some(MiniMis, ClientList, Nameservice, LogFile).