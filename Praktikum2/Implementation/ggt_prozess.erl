-module(ggt_prozess).
-export([start/3]).

% Arbeitszeit 	:: Integer 	-> Simulierte Arbeitszeit in Millisekunden fuer das Berechnen eines Durchlaufes durch die Berechnungsschleife
% Wartezeit 	:: Integer 	-> Zeit in Millisekunden die maximal auf eine neue Nachricht gewartet wird bis eine Abstimmung startet
% Name			:: Atom 	-> Zu registrierender Eigenname des GGT-Prozesses
start(Arbeitszeit, Wartezeit, Name) ->
	% Config-Values suchen
	{ok, ConfigListe} = file:consult("ggt.cfg"),
	{ok, NameserviceNode} = util:get_config_value(nameservicenode, ConfigListe),
	{ok, KoordinatorName} = util:get_config_value(koordinatorname, ConfigListe),

	% Warte darauf, dass der Nameservice verfuegbar ist
	wait_for_nameservice(NameserviceNode),
	
  	% Ermittle die PID des Nameservice
	Nameservice = global:whereis_name(nameservice),

	% Versuche den eigenen Namen beim Nameservice zu binden
	case util:bind_name(Nameservice, Name) of
		ok -> 
			util:logging("GGT.log", "Name " ++ atom_to_list(Name) ++ " erfolgreich registriert");
		in_use -> 
			util:logging("GGT.log", "Name " ++ atom_to_list(Name) ++ " schon in benutzung - Beende Prozess"),
			error
	end,

	loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, -1, -1, -1, util:time_in_ms()),

	% Melde beim Nameservice ab
	util:unbind_name(Nameservice, Name).

loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, Timestamp) ->
	receive
		{setneighbors, LeftN, RightN} ->
			loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftN, RightN, util:time_in_ms());
		{setpm, NewMi} ->
			loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, NewMi, LeftNeighbor, RightNeighbor, util:time_in_ms());
		{sendy, Y} ->
			NewMi = euklid(Mi, Y),
			if
				NewMi == Mi ->
					loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, util:time_in_ms());
				NewMi =/= Mi ->
					util:lookup_name(Nameservice, LeftNeighbor) ! {sendy, NewMi},
					util:lookup_name(Nameservice, RightNeighbor) ! {sendy, NewMi},
					loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, util:time_in_ms())
			end;
		{abstimmung, Initiator} ->
			case Name == Initiator of
				true ->
					util:lookup_name(Nameservice, Koordinator) ! {briefterm, {Name, Mi, util:timeMilliSecond()}},
					loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, util:time_in_ms());
				false ->
					case ()util:time_in_ms() - Timestamp) > ()Wartezeit / 2) of
						true ->
							util:lookup_name(Nameservice, RightNeighbor) ! {abstimmung, Initiator};
						false ->
							loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, util:time_in_ms());
					end;
			end,
			
			
		{tellmi, From} ->
			util:lookup_name(Nameservice, From) ! {mi, Mi},
			loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, util:time_in_ms());
		{pingGGT, From} ->
			util:lookup_name(Nameservice, From) ! {pongGGT, Name},
			loop(Arbeitszeit, Wartezeit, Name, KoordinatorName, Nameservice, Mi, LeftNeighbor, RightNeighbor, util:time_in_ms());
		kill -> ok
	after 
		Wartezeit ->
			util:lookup_name(Nameservice, RightNeighbor) ! {abstimmung, Name}
	end.


% Hilfsfunktionen
wait_for_nameservice(NameserviceNode) ->
	Answer = net_adm:ping(NameserviceNode),
	
	if 
		Answer == pang -> 
			timer:sleep(50),
			wait_for_nameservice(NameserviceNode);
		Answer == pong ->
			ok
	end.
