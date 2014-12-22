-module(data_source_test).
-export([start/0]).

start() ->
	DataSource = data_source:start(),
	DataSource ! {set_listener, self()},
	loop().

loop() ->
	receive
		{payload, Payload} ->
			io:fwrite("Received data: ~p (~p)~n", [Payload, length(Payload)]),
			io:fwrite("String value ~s~n-------------~n", [Payload])
	end,
	loop().


