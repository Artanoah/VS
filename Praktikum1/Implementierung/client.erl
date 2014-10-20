-module(client).
-export([startClient/5]).

startClient(Lifetime, SendeIntervall, ClientName, ServerName, Rechnername) ->
	LogFileName = util:get_client_log_file(Rechnername),
	util:logging(LogFileName, ClientName ++ " Start: " ++ util:timeMilliSecond() ++ "\n"),

	timer:kill_after(1000*Lifetime),
	sending(Lifetime, SendeIntervall, ClientName, ServerName, LogFileName).
	
sending(Lifetime, SendeIntervall, ClientName, ServerName, LogFileName) ->
	MSGIDList = clientEditor:startSend(SendeIntervall, ClientName, ServerName),
	clientReader:startRead(ServerName, MSGIDList),
	NewSendeIntervall = calcTimer(SendeIntervall),
	sending(Lifetime, NewSendeIntervall, ClientName, ServerName, LogFileName).


calcTimer(SendeIntervall) ->
	case random:uniform(2) of
		1 ->
			NewIntervall = SendeIntervall - 1;
		2 ->
			NewIntervall = SendeIntervall + 1
	end,
	
	case NewIntervall < 2 of
		true ->
			2;
		false ->
			NewIntervall
	end.