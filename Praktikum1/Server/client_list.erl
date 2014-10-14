-module(client_list).
-export([create_new/0, add/2, exists/2, update/2, set_time/3,last_message_id/2]).

create_new() ->
	[].

add(ClientID, Queue) ->
	[{ClientID, 0, util:time_in_ms()}] ++ Queue.


exists(_ID, []) ->
	false;

exists(ID, [{ID, _LastNumber, _Time} | _Queue]) ->
	true;

exists(ID, [_ | Queue]) ->
	exists(ID, Queue).


update(_, []) ->
	[];

update(CurrentTime, [{_Nr, _LastNumber, ClientTime} | Queue]) when ClientTime + 8000 =< CurrentTime ->
	update(CurrentTime, Queue);

update(CurrentTime, [Client | Queue]) ->
	[Client] ++ update(CurrentTime, Queue).


set_time(_, _, []) ->
	[];

set_time(ClientID, CurrentTime, [{ClientID, LastNumber, _Time} | Queue]) ->
	[{ClientID, LastNumber, CurrentTime} | Queue];

set_time(ClientID, CurrentTime, [ Client | Queue]) ->
	[Client | set_time(ClientID, CurrentTime, Queue)].


last_message_id(_, []) ->
	false;

last_message_id(ClientID, [{ClientID, Nr, _} | Queue]) ->
	Nr;

last_message_id(ClientID, Queue) ->
	last_message_id(Queue).
