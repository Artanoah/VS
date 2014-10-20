-module(server).
-export([startServer/0]).


startServer() ->
	%Lese Konfigurationsdatei
	{ok, ConfigListe} = file:consult("server.cfg"),
    {ok, Latency} = util:get_config_value(latency, ConfigListe),
	{ok, ClientLifetime} = util:get_config_value(clientlifetime, ConfigListe),
	{ok, ServerName} = util:get_config_value(servername, ConfigListe),
	{ok, DlqLimit} = util:get_config_value(dlqlimit, ConfigListe),
	
	%Registriere ServerThread
	erlang:register(ServerName,self()),
	
	%Erstelle HBQ, DLQ und ClientList
	HBQ = hbq:createHBQ(),
	DLQ = dlq:createDLQ(DlqLimit),
	ClientList = nachrichtendienst:createClientList(),
	LogFileName = util:get_server_log_file(),
	
	%Logging
	util:logging(LogFileName, "Server Startzeit: " ++ util:timeMilliSecond() ++ " mit PID " ++ pid_to_list(self()) ++ "\n"),
	
	%Starte Dispatcher-Loop
	dispatcher_loop(HBQ, DLQ, ClientList, ConfigListe, Latency, ClientLifetime, ServerName, DlqLimit, 1, LogFileName).


dispatcher_loop(HBQ, DLQ, ClientList, ConfigListe, Latency, ClientLifetime, ServerName, DlqLimit, FreeMSGID, LogFileName) ->
	
	receive
		{getmsgid, PID} ->
			PID ! {nid, FreeMSGID},
			util:logging(LogFileName, "NachrichtenNr " ++ integer_to_list(FreeMSGID) ++ " an " ++ pid_to_list(PID) ++ " gesendet\n"),
			dispatcher_loop(HBQ, DLQ, ClientList, ConfigListe, Latency, ClientLifetime, ServerName, DlqLimit, FreeMSGID + 1, LogFileName)
			;
		{dropmessage, {Nachricht, Number}} ->
			{NewHBQ, NewDLQ} = hbq:dropmessage(HBQ, DLQ, {Nachricht, Number}),
			{Msg, COut, _, _, _} = Nachricht,
			util:logging(LogFileName, Msg ++ " "++ integer_to_list(Number) ++ "te_Nachricht. COut: " ++ COut ++ " HBQ In: " ++ util:timeMilliSecond() ++ " -dropmessage\n"),
			dispatcher_loop(NewHBQ, NewDLQ, ClientList, ConfigListe, Latency, ClientLifetime, ServerName, DlqLimit, FreeMSGID, LogFileName)
			;
		{getmessages, PID} ->
			NewClientList = nachrichtendienst:getMSG(DLQ, PID, ClientList, ClientLifetime),
			dispatcher_loop(HBQ, DLQ, NewClientList, ConfigListe, Latency, ClientLifetime, ServerName, DlqLimit, FreeMSGID, LogFileName)

	after
		Latency * 1000 ->
			util:logging(LogFileName, "Downtime: " ++ util:timeMilliSecond() ++ " vom Nachrichtenserver " ++ pid_to_list(self()) ++ "; Anzahl Restnachrichten in der HBQ:" ++ integer_to_list(length(HBQ)) ++ "\n"),
			util:logstop(),
			erlang:unregister(ServerName)
	end.