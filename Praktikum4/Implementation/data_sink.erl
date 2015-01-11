-module(data_sink).
-export([start/1]).


start(LogFileName) ->
	receive
		{data, Data} ->
			util:logging(LogFileName, "Message Received: " ++ Data),
			start(LogFileName)
	end.