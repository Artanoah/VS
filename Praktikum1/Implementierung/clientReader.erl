-module(clientReader).
-export([startRead/2]).


startRead(ServerName, MSGIDList) ->
	LogFileName = util:get_client_log_file(),
	
	MessagesDone = loop(ServerName, MSGIDList, [], LogFileName).
	
loop(ServerName, MSGIDList, MessagesDone, LogFileName) ->
	
	ServerName ! {getmessages, self()},
	
	receive
		{reply, Number, {Msg, COut, HBQIn, DLQIn, _}, Terminated} ->
			Message = {Msg, COut, HBQIn, DLQIn, util:timeMilliSecond()}
	end,
	
	case lists:member(Number, MSGIDList) of
		true -> 
			util:logging(LogFileName, 
				Msg ++ " " ++ integer_to_list(Number) ++ "te_Nachricht. COut: " ++ COut ++ 
				" HBQ In: " ++ HBQIn ++ "DLQ In: " ++ DLQIn ++ "*******" ++"C In:" ++ util:timeMilliSecond() ++ "\n"),
				NewMSGIDDoneList = [Number] ++ MessagesDone
				;
		false -> 
			util:logging(LogFileName, 
				Msg ++ " " ++ integer_to_list(Number) ++ "te_Nachricht. COut: " ++ COut ++ 
				" HBQ In: " ++ HBQIn ++ "DLQ In: " ++ DLQIn ++ "C In:" ++ util:timeMilliSecond() ++ "\n"),
			NewMSGIDDoneList = MessagesDone
	end,
	
	case Terminated of
		false ->
			loop(ServerName, MSGIDList, NewMSGIDDoneList, LogFileName);
		true ->
			util:logging(LogFileName, "..getmessages..Done..\n"),
			NewMSGIDDoneList
	end.