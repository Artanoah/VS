-module(clientReader).
-export([startRead/2]).


startRead(ServerName, MSGIDList) ->
	MessagesDone = loop(ServerName, MSGIDList, []).
	
loop(ServerName, MSGIDList, MessagesDone) ->
	
	ServerName ! {getmessages, self()},
	
	receive
		{reply, Number, {Msg, COut, HBQIn, DLQIn, _}, Terminated} ->
			Message = {Msg, COut, HBQIn, DLQIn, util:timeMilliSecond()}
	end,
	
	case lists:member(Number, MSGIDList) of
		true -> NewMSGIDDoneList = [Number] ++ MessagesDone;
		false -> NewMSGIDDoneList = MessagesDone
	end,
	
	case Terminated of
		false ->
			loop(ServerName, MSGIDList, NewMSGIDDoneList);
		true ->
			NewMSGIDDoneList
	end.