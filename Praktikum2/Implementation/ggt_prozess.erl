-module(ggt_prozess).
-export([start/3]).

% Arbeitszeit 	:: Integer 	-> Simulierte Arbeitszeit in Millisekunden fuer das Berechnen eines Durchlaufes durch die Berechnungsschleife
% Wartezeit 	:: Integer 	-> Zeit in Millisekunden die maximal auf eine neue Nachricht gewartet wird bis eine Abstimmung startet
% Name			:: Atom 	-> Zu registrierender Eigenname des GGT-Prozesses
start(Arbeitszeit, Wartezeit, Name) ->
	% Config-Values suchen
	{ok, ConfigListe} = file:consult("ggt.cfg"),
	{ok, NameserviceNode} = util:get_config_value(nameservicenode, ConfigListe),
	{ok, NameserviceName} = util:get_config_value(nameservicename, ConfigListe),
	{ok, KoordinatorName} = util:get_config_value(koordinatorname, ConfigListe),
	LogFile = atom_to_list(Name) ++ "GGT.log",

	% Warte darauf, dass der Nameservice verfuegbar ist
	util:wait_for_nameservice(NameserviceNode),
	
  	% Ermittle die PID des Nameservice
	Nameservice = global:whereis_name(NameserviceName),

	% Versuche den eigenen Namen beim Nameservice zu binden
	case util:bind_name(Nameservice, Name, NameserviceNode) of
		ok -> 
			util:logging(LogFile, "Name " ++ atom_to_list(Name) ++ " erfolgreich registriert\n");
		in_use -> 
			util:logging(LogFile, "Name " ++ atom_to_list(Name) ++ " schon in benutzung - Beende Prozess\n"),
			erlang:error("Name bereits vergeben\n")
	end,
	
	% Melde dich beim Koordinator an
	util:send_message_to({hello, Name}, KoordinatorName, Nameservice),
	
	% Warte auf eine erste Nachricht
	%So gehen sie in die Arbeitsphase während der Koordinator den Ring aufbaut, sollten sie nicht erst in ihre Arbeitsschleife gehen wenn sie angestubst werden? Von Koordinator oder Nachbar?
	wait_for_first_message(),
	
	% GGT-Prozessloop
	loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, -1, -1, -1, util:time_in_ms(), LogFile),

	% Melde beim Nameservice ab
	util:unbind_name(Nameservice, Name).

loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, Timestamp, LogFile) ->
	receive
		{setneighbors, LeftN, RightN} ->
			util:logging(LogFile, atom_to_list(Name) ++ ": linker Nachbar " ++ atom_to_list(LeftN) ++ " ich: " ++ atom_to_list(Name) ++ " rechter Nachbar " ++ atom_to_list(RightN) ++ "\n"),
			wait_for_first_message(),
			loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftN, RightN, util:time_in_ms(), LogFile);

		{setpm, NewMi} ->
			util:logging(LogFile, atom_to_list(Name) ++ ": Mi auf " ++ integer_to_list(NewMi) ++ " gesetzt\n"),
			wait_for_first_message(),
			loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, NewMi, LeftNeighbor, RightNeighbor, util:time_in_ms(), LogFile);

		{sendy, Y} ->
			util:logging(LogFile, atom_to_list(Name) ++ ": Berechne Mi: " ++ integer_to_list(Mi) ++ " Y: " ++ integer_to_list(Y) ++ "\n"),
			timer:sleep(Arbeitszeit),
			NewMi = euklid(Mi, Y),
			case NewMi < Mi of
				false ->
					loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, util:time_in_ms(), LogFile);
				
				true -> 
					util:send_message_to({sendy, NewMi}, LeftNeighbor, Nameservice),
					util:send_message_to({sendy, NewMi}, RightNeighbor, Nameservice),
					util:send_message_to({briefmi, {Name, Mi, util:timeMilliSecond()}}, KoordinatorName, Nameservice),
					loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, NewMi, LeftNeighbor, RightNeighbor, util:time_in_ms(), LogFile)
			end;
				
		{abstimmung, Initiator} ->
			case Name == Initiator of
				true ->
					util:logging(LogFile, atom_to_list(Name) ++ ": Abstimmung erfolgreich beendet\n"),
					util:send_message_to({briefterm, {Name, Mi, util:timeMilliSecond()}, self()}, KoordinatorName, Nameservice),
					wait_for_first_message(),
					loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, Timestamp, LogFile);
				false ->
					case (util:time_in_ms() - Timestamp) > (Wartezeit / 2) of
						true ->
							util:logging(LogFile, atom_to_list(Name) ++ ": Abstimmungsanfrage erhalten - nehme an\n"),
							util:send_message_to({abstimmung, Initiator}, RightNeighbor, Nameservice),
							wait_for_first_message(),
							loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, Timestamp, LogFile);
						false ->
							util:logging(LogFile, atom_to_list(Name) ++ ": Abstimmungsanfrage erhalten - lehne ab\n"),
							loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, Timestamp, LogFile)
					end
			end;
			
		{tellmi, From} ->
			util:send_message_to({mi, Mi}, From, Nameservice),
			loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, Timestamp, LogFile);
		
		{pingGGT, From} ->
			util:send_message_to({pongGGT, Name}, From, Nameservice),
			loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, Timestamp, LogFile);
		
		kill -> 
			util:logging(LogFile, atom_to_list(Name) ++ ": Beendet\n"),
			ok;

		_ ->
			util:logging(LogFile, "Unbekannte / unerwartete Nachricht erhalten\n"),
			loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, Timestamp, LogFile)

	after 
		Wartezeit ->
			util:logging(LogFile, atom_to_list(Name) ++ ": Starte Abstimmung\n"),
			util:send_message_to({abstimmung, Name}, RightNeighbor, Nameservice),
			wait_for_first_message(),
			loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, Timestamp, LogFile)
	end.


% Hilfsfunktionen

euklid(Mi, Y) ->
	case Y < Mi of
		true ->
			((Mi - 1) rem Y) + 1;
		false ->
			Mi
	end.


wait_for_first_message() ->
	receive 
		Message ->
			self() ! Message
	end.