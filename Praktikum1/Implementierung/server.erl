-module(server).
-export([startServer/0]).


startServer() ->
	%Lese Konfigurationsdatei
	{ok, ConfigListe} = file:consult("server.cfg"),
    {ok, Latency} = util:get_config_value(latency, ConfigListe),
	{ok, ClientLifetime} = util:get_config_value(clientlifetime, ConfigListe),
	{ok, ServerName} = util:get_config_value(servername, ConfigListe),
	{ok, DlqLimit} = util:get_config_value(dlqlimit, ConfigListe),
	
	%Erstelle HBQ, DLQ und ClientList
	HBQ = hbq:createHBQ(),
	DLQ = dlq:createDLQ(DlqLimit),
	ClientList = nachrichtendienst:createClientList(),
	
	%Starte Dispatcher-Loop
	dispatcher_loop(HBQ, DLQ, ClientList, ConfigListe, Latency, ClientLifetime, ServerName, DlqLimit, 1).


dispatcher_loop(HBQ, DLQ, ClientList, ConfigListe, Latency, ClientLifetime, ServerName, DlqLimit, FreeMSGID) ->
	
	receive
		{getmsgid, PID} ->
			PID ! {nid, FreeMSGID},
			dispatcher_loop(HBQ, DLQ, ClientList, ConfigListe, Latency, ClientLifetime, ServerName, DlqLimit, FreeMSGID + 1)
			;
		{dropmessage, {Nachricht, Number}} ->
			{NewHBQ, NewDLQ} = hbq:dropmessage(HBQ, DLQ, {Nachricht, Number}),
			dispatcher_loop(NewHBQ, NewDLQ, ClientList, ConfigListe, Latency, ClientLifetime, ServerName, DlqLimit, FreeMSGID)
			;
		{getmessages, PID} ->
			NewClientList = nachrichtendienst:getMSG(DLQ, PID, ClientList, ClientLifetime),
			dispatcher_loop(HBQ, DLQ, NewClientList, ConfigListe, Latency, ClientLifetime, ServerName, DlqLimit, FreeMSGID)

	after
		Latency ->
			server_timed_out
	end.