-module(clientCreator).
-export([start/0]).

start() ->
	{ok, ConfigListe} = file:consult("client.cfg"),
    {ok, Clients} = util:get_config_value(clients, ConfigListe),
	{ok, Lifetime} = util:get_config_value(lifetime, ConfigListe),
	{ok, ServerName} = util:get_config_value(servername, ConfigListe),
	{ok, SendeIntervall} = util:get_config_value(sendeintervall, ConfigListe),
	{ok, PraktikumsGruppe} = util:get_config_value(praktikumsgruppe, ConfigListe),
	{ok, Rechnername} = util:get_config_value(rechnername, ConfigListe),
	{ok, Teamnummer} = util:get_config_value(teamnummer, ConfigListe),
	
	%Warte darauf, dass der Server gestartet und registriert wurde.
	waitForServer(ServerName),
	
	%Spawne alle Clients
	createClients(Clients, Lifetime, SendeIntervall, ServerName, Rechnername, PraktikumsGruppe, Teamnummer).
	
waitForServer(ServerName) ->
	Name = erlang:whereis(ServerName),
	case Name of
		undefined -> 
			timer:sleep(50),
			waitForServer(ServerName);
		_ -> ok
	end.


createClients(Clients, _, _, _, _, _, _) when Clients == 0 ->
	clients_created;

createClients(Clients, Lifetime, SendeIntervall, ServerName, Rechnername, PraktikumsGruppe, Teamnummer) ->
	ClientName = createClientName(Clients, Rechnername, PraktikumsGruppe, Teamnummer),
	spawn(client, startClient, [Lifetime, SendeIntervall, ClientName, ServerName]),
	createClients(Clients - 1, Lifetime, SendeIntervall, ServerName, Rechnername, PraktikumsGruppe, Teamnummer).


createClientName(ID, Rechnername, PrakGr, TeamNr) ->
	integer_to_list(ID) ++ "-client@" ++ atom_to_list(Rechnername) ++ "-" ++ pid_to_list(self()) ++ "-Gruppe" ++ integer_to_list(PrakGr) ++ "-" ++ integer_to_list(TeamNr)
	.