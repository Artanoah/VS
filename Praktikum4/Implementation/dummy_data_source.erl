-module(dummy_data_source).
-export([start/0]).


start() ->
	receive
		{get_payload, PID} ->
			PID ! {payload, "DUMMY_STRING"}
	end.