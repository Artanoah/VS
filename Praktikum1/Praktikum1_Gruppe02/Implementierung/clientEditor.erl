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
	
	%Logging
	util:logging(LogFileName, integer_to_list(MSGID) ++ "te Nachricht um " ++ util:timeMilliSecond() ++ " vergessen zu senden\n"),

	%Gib die Liste der versendeten Nachrichten zurueck
	MSGIDList.
	
%Loop für das Anfragen nach Nachrichtennummern und verschicken von Nachrichten.
loop(_, _, _, MSGIDList, Counter, _) when Counter == 0 ->
	MSGIDList;
	
loop(SendeIntervall, ClientName, ServerName, MSGIDList, Counter, LogFileName) ->
	%Fordere eine Nachrichtennummer vom Server an
	ServerName ! {getmsgid, self()},
	
	%Warte den vorgegebenen Sendeintervall
	timer:sleep(SendeIntervall * 1000),

	%Empfange die Nachrichtennummer
	receive
		{nid, Number} ->
			MSGID = Number
	end,
	
	%Speichere einen Timestamp
	Time = util:timeMilliSecond(),

	%Schicke dem Server eine Nachricht die er an alle anderen Teilnehmer verteilen soll
	ServerName ! {dropmessage, {{ClientName, Time, 0, 0, 0}, MSGID}},
	
	%Logging
	util:logging(LogFileName, ClientName ++ ": " ++ integer_to_list(MSGID) ++ "te_Nachricht. C Out: " ++ Time ++ " gesendet\n"),
	
	loop(SendeIntervall, ClientName, ServerName, [MSGID] ++ MSGIDList, Counter - 1, LogFileName).