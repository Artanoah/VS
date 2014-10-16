-module(hbq).
-export([createHBQ/0, dropmessage/4]).


createHBQ() ->
	[].


dropmessage({{Text, COut, _, DLQIn, ClientIn}, Nr}, MaxDLQSize, HBQueue, DLQueue) ->
	HBQueueFilled = lists:keysort(2, [{{Text, COut, util:timeMilliSecond(), DLQIn, ClientIn}, Nr} | HBQueue]),
	
	case hbqFollowsDlq(HBQueueFilled, DLQueue) or is_hbq_full(HBQueue, MaxDLQSize) of
		true	-> {HBQueueDone, DLQueueDone} = fill_until_error(MaxDLQSize, util:tail(HBQueueFilled), dlq:add(util:head(HBQueueFilled),MaxDLQSize, DLQueue));
		false 	-> {HBQueueDone, DLQueueDone} = {HBQueueFilled, DLQueue}
	end,
	{HBQueueDone, DLQueueDone}.


%Hilfsmethoden
fill_until_error(_, [], DLQ) ->
	{[], DLQ};

fill_until_error(MaxDLQSize, HBQ, DLQ)  ->
	case hbqFollowsDlq(HBQ, DLQ) of
		true 	-> fill_until_error(MaxDLQSize, util:tail(HBQ), dlq:add(util:head(HBQ), MaxDLQSize, DLQ));
		false	-> {HBQ, DLQ}
	end.


hbqFollowsDlq([], _) ->
	true;

hbqFollowsDlq(HBQ, DLQ) ->
	get_num(util:head(HBQ)) - 1 == get_num(util:last(DLQ)).


get_num({_, Nr}) ->
	Nr.


is_hbq_full(Queue, MaxDLQSize) ->
	MaxDLQSize div 2 =< length(Queue).
