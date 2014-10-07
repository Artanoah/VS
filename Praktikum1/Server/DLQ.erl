-module(dlq).
-export([create_new/0, add/3]).

create_new() -> 
	[].
	
add(Msg, Nr, Queue) ->
	case full(Queue) of
		true	-> 	lists:keysort(2, [{Msg, Nr}] ++ delete_first(Queue));
		false 	->	lists:keysort(2, [{Msg, Nr}] ++ Queue)
	end.
		
		
full(Queue) ->
	second_entry(application:get_env(server, dlq_max_size)) =< length(Queue).
	
second_entry({_, Val}) ->
	Val.
	
delete_first([_X|XS]) ->
	XS.