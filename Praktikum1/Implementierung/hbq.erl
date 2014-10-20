-module(hbq).
-export([createHBQ/0, dropmessage/3]).


createHBQ() ->
	[].

	
dropmessage(HBQueue, DLQueue, {{Text, COut, _, DLQIn, ClientIn}, Nr}) ->
	{ok, ConfigListe} = file:consult("server.cfg"),
	{ok, ServerName} = util:get_config_value(servername, ConfigListe),
	LogFileName = "Server_" ++ lists:droplast(util:tail(pid_to_list(self()))) ++ "_" ++ atom_to_list(ServerName) ++ ".log",

	case Nr < dlq:getMaxID(DLQueue) of
		%Wenn die neue Nachricht zu alt ist um noch in die DLQ eingereiht zu werden lasse sie einfach aus
		true ->
			{HBQueue, DLQueue}
			;
		%Wenn die neue Nachricht noch jetzt oder spaeter in die DLQ eingereiht werden kann
		false ->
			HBQueueFilled = lists:keysort(2, [{{Text, COut, util:timeMilliSecond(), DLQIn, ClientIn}, Nr} | HBQueue]),
			
			case is_hbq_full(HBQueueFilled, dlq:maxSize(DLQueue)) of
				true -> 
					{_, LastMessageNumber} = util:head(HBQueueFilled),
					ErrorText = "***Fehlernachricht fuer Nachrichten " ++ integer_to_list(dlq:getMaxID(DLQueue)) ++ " bis " ++ integer_to_list(LastMessageNumber) ++ " um " ++ util:timeMilliSecond() ++ "\n",
					ErrorMessage = {{ErrorText, "", "", "", ""}, LastMessageNumber - 1},
					DLQueueFilled = dlq:add(DLQueue, ErrorMessage),
					util:logging(LogFileName, ErrorText);
				false ->
					DLQueueFilled = DLQueue
			end,
					
			
			case hbqFollowsDlq(HBQueueFilled, DLQueueFilled) of
				true	-> 
					{_, HeadNum} = util:head(HBQueueFilled),
					{HBQueueDone, DLQueueDone, Log} = fill_until_error(dlq:maxSize(DLQueueFilled), [HeadNum], util:tail(HBQueueFilled), dlq:add(DLQueueFilled, util:head(HBQueueFilled))),
					util:logging(LogFileName, "QVerwaltung>>> Nachrichten " ++ integer_to_list(lists:min(Log)) ++ " bis " ++ integer_to_list(lists:max(Log)) ++ " von HBQ in DLQ transferiert\n");
				false 	-> 
					{HBQueueDone, DLQueueDone} = {HBQueueFilled, DLQueueFilled}
			end,
			{HBQueueDone, DLQueueDone}
	end.
			


%Hilfsmethoden
fill_until_error(_, Log, [], DLQ) ->
	{[], DLQ, Log};

fill_until_error(MaxDLQSize, Log, HBQ, DLQ)  ->
	case hbqFollowsDlq(HBQ, DLQ) of
		true 	-> 
			{_, HeadNum} = util:head(HBQ),
			fill_until_error(MaxDLQSize, [HeadNum] ++ Log, util:tail(HBQ), dlq:add(DLQ, util:head(HBQ)));
		false	-> 
			{HBQ, DLQ, Log}
	end.


hbqFollowsDlq([], _) ->
	false;

hbqFollowsDlq(HBQ, DLQ) ->
	get_num(util:head(HBQ)) - 1 == get_num(util:last(DLQ)).


get_num({_, Nr}) ->
	Nr.


is_hbq_full(Queue, MaxDLQSize) ->
	MaxDLQSize div 2 < length(Queue).