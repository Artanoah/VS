-module(client_list).
-export([create_new/0, add/2, exists/2, update/3, set_time/3, get_last_message_id/2, set_last_message_id/3]).


create_new() ->
	[].


add(ClientID, Queue) ->
	[{ClientID, 0, util:time_in_ms()}] ++ Queue.


exists(_, []) ->
	false;

exists(ID, [{ID, _LastNumber, _Time} | _Queue]) ->
	true;

exists(ID, [_ | Queue]) ->
	exists(ID, Queue).


update(_, _, []) ->
	[];

update(CurrentTime, ClientLifetime, [{_Nr, _LastNumber, ClientTime} | Queue]) when ClientTime + ClientLifetime =< CurrentTime ->
	update(CurrentTime, ClientLifetime, Queue);

update(CurrentTime, ClientLifetime, [Client | Queue]) ->
	[Client] ++ update(CurrentTime, ClientLifetime, Queue).


set_time(_, _, []) ->
	[];

set_time(ClientID, CurrentTime, [{ClientID, LastNumber, _Time} | Queue]) ->
	[{ClientID, LastNumber, CurrentTime} | Queue];

set_time(ClientID, CurrentTime, [Client | Queue]) ->
	[Client | set_time(ClientID, CurrentTime, Queue)].


get_last_message_id(_, []) ->
	false;

get_last_message_id(ClientID, [{ClientID, Nr, _} | _]) ->
	Nr;

get_last_message_id(ClientID, [_ | Queue]) ->
	get_last_message_id(ClientID, Queue).


set_last_message_id(_, _, []) -> 
	[];

set_last_message_id(ClientID, NewID, [{ClientID, _, Time} | Queue]) -> 
	[{ClientID, NewID, Time} | Queue];

set_last_message_id(ClientID, NewID, [Head | Queue]) -> 
	[Head | set_last_message_id(ClientID, NewID, Queue)].