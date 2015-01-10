-module(data_source).
-export([start/0]).


start() -> 
	MessageLoop = spawn(fun() -> messageLoop("DUMMYMESSAGEDUMMYMESSAGE") end),
	spawn(fun() -> dataLoop(io:get_chars("", 24), MessageLoop) end).


dataLoop(LastData, MessageLoop) ->
	MessageLoop ! {data, LastData},
	dataLoop(io:get_chars("", 24), MessageLoop).


messageLoop(LastData) ->
	receive
		{data, NewData} ->
			messageLoop(NewData);
			
		{get_payload, PID} ->
			PID ! {payload, LastData},
			messageLoop(LastData)
	end.