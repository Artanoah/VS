-module(clientEditor).
-export([startSend/3]).

startSend(SendeIntervall, ClientName, ServerName) ->
	MSGIDList = loop(SendeIntervall, ClientName, ServerName, [], 5),
	
	ServerName ! {getmsgid, self()},
	MSGIDList.
	
loop(_, _, _, MSGIDList, Counter) when Counter == 0 ->
	MSGIDList;
	
loop(SendeIntervall, ClientName, ServerName, MSGIDList, Counter) ->
	ServerName ! {getmsgid, self()},
	timer:sleep(SendeIntervall * 1000),
	receive
		{nid, Number} ->
			MSGID = Number
	end,
	
	ServerName ! {dropmessage, {{ClientName, util:timeMilliSecond(), 0, 0, 0}, MSGID}},
	
	loop(SendeIntervall, ClientName, ServerName, [MSGID] ++ MSGIDList, Counter - 1).