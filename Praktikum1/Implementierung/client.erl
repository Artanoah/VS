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
	util:logging(LogFileName, "Neuer Sendeintervall: " ++ integer_to_list(NewSendeIntervall) ++ " Sekunden (" ++ integer_to_list(SendeIntervall) ++ ")\n"),
	sending(Lifetime, NewSendeIntervall, ClientName, ServerName, LogFileName).


calcTimer(SendeIntervall) ->
	case random() of
		true ->
			NewIntervall = SendeIntervall - 1;
		false ->
			NewIntervall = SendeIntervall + 1
	end,
	
	case NewIntervall < 2 of
		true ->
			2;
		false ->
			NewIntervall
	end.

random()	->
	{_, _, MS} = os:timestamp(),
	case (MS div 1000) rem 2 of
		0 -> true;
		1 -> false
	end.