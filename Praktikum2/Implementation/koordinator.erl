-module(koordinator).
-export([start/0]).

start() -> 
	% Config-Krams
	{ok, ConfigListe} = file:consult("korrdinator.cfg"),
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
	case util:bind_name(Nameservice, KoordinatorName) of
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
			PID ! {steeringval, Arbeitszeit, Wartezeit, GGTProzessAnzahl},
			initialize_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile);

		{hello, ClientName} ->
			initialize_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, [ClientName | ClientList], LogFile);

		{step, PID} ->
			PID ! ok,
			ShuffeledClientList = util:shuffle(ClientList),
			inform_all_about_neighbors(ShuffeledClientList, Nameservice),
			working_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile)
	end.

% Arbeitsphase
working_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile) ->
	receive
		{kill, PID} ->
			ending_loop(ClientList, Nameservice, LogFile);

		{reset, PID} -> 
			kill_all_GGTs(ClientList, Nameservice),
			PID ! ok,
			initialize_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, [], LogFile);

		{getsteeringval, From} ->
			PID = util:lookup_name(Nameservice, Head),
			PID ! rejected,
			working_loop(Nameservice, KoordinatorName, Arbeitszeit, Wartezeit, GGTProzessAnzahl, KorrigierenFlag, ClientList, LogFile);
		
		{hello, From} ->
			


% Beendigungsphase
ending_loop(ClientList, Nameservice, LogFile) ->
	kill_all_GGTs(ClientList, Nameservice),
	PID ! ok,
	ok.


% Hilfsmethoden
inform_all_about_neighbors(ClientList, Nameservice) ->
	inform_all_about_neighbors_helper(ClientList, ClientList, Nameservice).

inform_all_about_neighbors_helper([Head | Tail1], [Head | Tail2], Nameservice) ->
	PID = util:lookup_name(Nameservice, Head),
	PID ! {setneighbors, util:last(Tail2), util:head(Tail2)},
	inform_all_about_neighbors_helper(Tail1, [Head | Tail2], Nameservice);

inform_all_about_neighbors_helper([Head | []], ClientList, Nameservice) ->
	PID = util:lookup_name(Nameservice, Head),
	PID ! {setneighbors, util:element_before(Head, ClientList), util:head(ClientList)};

inform_all_about_neighbors_helper([Head, Tail], ClientList, Nameservice) ->
	PID = util:lookup_name(Nameservice, Head),
	PID ! {setneighbors, util:element_before(Head, ClientList), util:element_after(Head, ClientList)},
	inform_all_about_neighbors_helper(Tail, ClientList, Nameservice).


kill_all_GGTs([], _) ->
	ok;

kill_all_GGTs([Head | Tail], Nameservice) ->
	PID = util:lookup_name(Nameservice, Head),
	PID ! kill,
	kill_all_GGTs(Tail, Nameservice).