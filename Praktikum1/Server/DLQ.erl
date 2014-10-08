-module(dlq).
-export([create_new/0, add/3, get/2]).

create_new() -> 
	[].
	
add(Msg, Nr, Queue) ->
	case full(Queue) of
		true	-> 	lists:keysort(2, [{Msg, Nr}] ++ delete_first(Queue));
		false 	->	lists:keysort(2, [{Msg, Nr}] ++ Queue)
	end.


get(_, []) ->
	false;

get(Nr, [{_, NNr} | XS]) when Nr /= NNr ->
	get(Nr, XS);

get(Nr, [{Nachricht, _} | XS]) when XS /= [] ->
	{Nachricht, Nr, true};

get(Nr, [{Nachricht, _} | _]) ->
	{Nachricht, Nr, false}.
	
		
		
full(Queue) ->
	second_entry(application:get_env(server, dlq_max_size)) =< length(Queue).
	
second_entry({_, Val}) ->
	Val.
	
delete_first([_|XS]) ->
	XS.