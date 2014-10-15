-module(hbq).
-export([createNew/0, add/4]).

createNew() ->
	[].


add({Text, COut, _, DLQIn, ClientIn}, Nr, HBQueue, DLQueue) ->
	HBQueueFilled = lists:keysort(2, [{{Text, COut, util:time_in_ms(), DLQIn, ClientIn}, Nr} | HBQueue]),
	
	case hbqFollowsDlq(HBQueueFilled, DLQueue) or is_hbq_full(HBQueue) of
		true	-> {HBQueueDone, DLQueueDone} = fill_until_error(util:tail(HBQueueFilled), dlq:add(util:head(HBQueueFilled), DLQueue));
		false 	-> {HBQueueDone, DLQueueDone} = {HBQueueFilled, DLQueue}
	end,
	{HBQueueDone, DLQueueDone}.


is_consistent([]) ->
	true;

is_consistent([_ | []]) ->
	true;

is_consistent([{_, Nr}, {Msg, NNr} | HBQ]) when Nr + 1 == NNr ->
	is_consistent([{Msg, NNr} | HBQ]);

is_consistent(_) ->
	false.


fill_until_error([], DLQ) ->
	{[], DLQ};

fill_until_error(HBQ, DLQ)  ->
	case hbqFollowsDlq(HBQ, DLQ) of
		true 	-> fill_until_error(util:tail(HBQ), dlq:add(util:head(HBQ), DLQ));
		false	-> {HBQ, DLQ}
	end.


hbqFollowsDlq([], _) ->
	true;

hbqFollowsDlq(HBQ, DLQ) ->
	get_num(util:head(HBQ)) - 1 == get_num(util:last(DLQ)).


get_num({_, Nr}) ->
	Nr.


is_hbq_full(HBQ) ->
	get_num(application:get_env(server, dlq_max_size) / 2) =< length(HBQ).