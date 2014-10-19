-module(client).
-export([startClient/4]).

startClient(Lifetime, SendeIntervall, ClientName, ServerName) ->
	timer:kill_after(1000*Lifetime),
	sending(Lifetime, SendeIntervall, ClientName, ServerName).
	
sending(Lifetime, SendeIntervall, ClientName, ServerName) ->
	MSGIDList = clientEditor:startSend(SendeIntervall, ClientName, ServerName),
	clientReader:startRead(ServerName, MSGIDList),
	NewSendeIntervall = calcTimer(SendeIntervall),
	sending(Lifetime, NewSendeIntervall, ClientName, ServerName).


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