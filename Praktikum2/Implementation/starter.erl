-module(starter).
-export([start/1]).

start(StarterNummer) ->
	%Auslesen der config Datei
	{ok,GGTConfig} = file:consult("ggt.cfg"),
	{ok, PraktikumsGruppe} = util:get_config_value(praktikumsgruppe,GGTConfig),
	{ok, TeamNummer} = util:get_config_value(teamnummer,GGTConfig),
	{ok, NameServiceNode} = util:get_config_value(nameservicenode,GGTConfig),
	{ok, NameServiceName} = util:get_config_value(nameservicename,GGTConfig),
	{ok, KoordinatorName} = util:get_config_value(koordinatorname,GGTConfig),
	LogFile = "starter" ++ integer_to_list(StarterNummer) ++ ".log",
	
	%Warte darauf, dass der NameService verfuegbar ist
	util:wait_for_nameservice(NameServiceNode),
	
	% Die PID des NameService herausfinden
	Nameservice = global:whereis_name(NameServiceName),
	
	% PID des Koordinator ueber den Nameservice herausfinden
	Koordinator = util:lookup_name(Nameservice, KoordinatorName),
	
	% Steuernde Werte vom Koordinator erfragen
	Koordinator ! {getsteeringval , self()},
	
	receive
		{steeringval, Arbeitszeit, Wartezeit, GGTProzessAnzahl} ->
			startGGTProcesses(Arbeitszeit, Wartezeit, GGTProzessAnzahl, StarterNummer, TeamNummer, PraktikumsGruppe);
		rejected ->
			util:logging(LogFile, "Koordinator " ++ atom_to_list(KoordinatorName) ++ " ist nicht in der Initialisierungsphase. Breche ab\n."),
			erlang:fault("Konnte nicht mit Koordinator verbinden\n")
	end.
	

startGGTProcesses(_, _, 0, _, _, _) ->
	ok;

startGGTProcesses(Arbeitszeit,Wartezeit,GGTProzessAnzahl, StarterNummer, TeamNummer, PraktikumsGruppe) ->
	spawn(ggt_prozess, start, [Arbeitszeit,Wartezeit,list_to_atom(lists:concat([PraktikumsGruppe, TeamNummer, GGTProzessAnzahl, StarterNummer]))]),
	startGGTProcesses(Arbeitszeit,Wartezeit,GGTProzessAnzahl - 1, StarterNummer, TeamNummer, PraktikumsGruppe).
