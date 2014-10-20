-module(clientEditor).
-export([startSend/3]).

startSend(SendeIntervall, ClientName, ServerName) ->
	%Logging
	LogFileName = util:get_client_log_file(),
	MSGIDList = loop(SendeIntervall, ClientName, ServerName, [], 5, LogFileName),
	
	%Lasse eine Nachricht aus
	ServerName ! {getmsgid, self()},
	receive
		{nid, Number} ->
			MSGID = Number
	end,

	util:logging(LogFileName, integer_to_list(MSGID) ++ "te Nachricht um " ++ util:timeMilliSecond() ++ " vergessen zu senden\n"),

	%Gib die Liste der versendeten Nachrichten zurueck
	MSGIDList.
	
loop(_, _, _, MSGIDList, Counter, _) when Counter == 0 ->
	MSGIDList;
	
loop(SendeIntervall, ClientName, ServerName, MSGIDList, Counter, LogFileName) ->
	ServerName ! {getmsgid, self()},
	timer:sleep(SendeIntervall * 1000),
	receive
		{nid, Number} ->
			MSGID = Number
	end,
	
	Time = util:timeMilliSecond(),
	ServerName ! {dropmessage, {{ClientName, Time, 0, 0, 0}, MSGID}},
	
	util:logging(LogFileName, ClientName ++ ": " ++ integer_to_list(MSGID) ++ "te_Nachricht. C Out: " ++ Time ++ " gesendet\n"),
	
	loop(SendeIntervall, ClientName, ServerName, [MSGID] ++ MSGIDList, Counter - 1, LogFileName).