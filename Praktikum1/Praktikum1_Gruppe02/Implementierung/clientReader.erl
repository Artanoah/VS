-module(clientReader).
-export([startRead/2]).

%Startet den Leser
startRead(ServerName, MSGIDList) ->
	%Logging
	LogFileName = util:get_client_log_file(),
	
	MessagesDone = loop(ServerName, MSGIDList, [], LogFileName).
	
%Lese-Loop
loop(ServerName, MSGIDList, MessagesDone, LogFileName) ->
	%Fordere eine neue Nachricht vom Server an
	ServerName ! {getmessages, self()},
	%Empfange die neue Nachricht
	receive
		{reply, Number, {Msg, COut, HBQIn, DLQIn, _}, Terminated} ->
			Message = {Msg, COut, HBQIn, DLQIn, util:timeMilliSecond()}
	end,
	
	%Pruefe ob die empfangene Nachricht eine selbst verschickte ist und logge dementsprechend ("********" wenn die Nachricht von sich selber verschickt wurde)s
	case lists:member(Number, MSGIDList) of
		true -> 
			util:logging(LogFileName, 
				Msg ++ " " ++ integer_to_list(Number) ++ "te_Nachricht. COut: " ++ util:timestamp_to_list(COut) ++ 
				" HBQ In: " ++ util:timestamp_to_list(HBQIn) ++ "DLQ In: " ++ util:timestamp_to_list(DLQIn) ++ "*******" ++"C In:" ++ util:timeMilliSecond() ++ "\n"),
				NewMSGIDDoneList = [Number] ++ MessagesDone
				;
		false -> 
			util:logging(LogFileName, 
				Msg ++ " " ++ integer_to_list(Number) ++ "te_Nachricht. COut: " ++ util:timestamp_to_list(COut) ++ 
				" HBQ In: " ++ util:timestamp_to_list(HBQIn) ++ "DLQ In: " ++ util:timestamp_to_list(DLQIn) ++ "C In:" ++ util:timeMilliSecond() ++ "\n"),
			NewMSGIDDoneList = MessagesDone
	end,
	
	%Wenn noch nicht die letzte Nachricht empfangen wurde, dann frage weiter ab, sonst beende dich.
	case Terminated of
		false ->
			loop(ServerName, MSGIDList, NewMSGIDDoneList, LogFileName);
		true ->
			util:logging(LogFileName, "..getmessages..Done..\n"),
			NewMSGIDDoneList
	end.