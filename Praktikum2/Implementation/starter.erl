-module[starter].
-export([start/1]).

start() ->
	%Auslesen der config Datei
	{ok,GGTConfig} = file:consult("ggt.cfg"),
	{ok, PraktikumsGruppe} = util:get_config_value(praktikumsgruppe,GGTConfig),
	{ok, TeamNummer} = util:get_config_value(teamnummer,GGTConfig),
	{ok, NameServiceNode} = util:get_config_value(nameservicenode,GGTConfig),
	{ok, NameServiceName} = util:get_config_value(nameservicename,GGTConfig),
	{ok, KoordinatorName} = util:get_config_value(koordinatorname,GGTConfig),
	LogFile = atom_to_list(
	
	%Warte darauf, dass der NameService verfuegbar ist
	wait_for_nmeservice(NameServiceNode},
	
	% Die PID des NameService herausfinden
	Nameservice = global.whereis_name(NameServiceName},
	
	% PID des Koordinator ueber den Nameservice herausfinden
	Koordinator = util:lookup_name(Nameservice, KoordinatorName}
	
	% Steuernde Werte vom Koordinator erfragen
	Koordinator ! {getsteeringval , self()},
	
	receive
		{steeringval, Arbeitszeit, Wartezeit, GGTProzessAnzahl} ->
			startGGTProcesses(Arbeitszeit, Wartezeit, GGTProzessAnzahl)
	end.
	
startGGTProcesses(Arbeitszeit,Wartezeit,GGTProzessAnzahl}) when GGTProzessAnzahl > 0 ->
	spawn(ggt:start(Arbeitszeit,Wartezeit,list_to_atom(lists:concat([PraktikumsGruppe, TeamNummer, GGTProzessNummer, StarterNumber])))),
	startGGTProcesses(Arbeitszeit,Wartezeit,GGTProzessAnzahl-1);
startGGTProcesses(Arbeitszeit,Wartezeit,GGTProzessAnzahl}) ->
	true.