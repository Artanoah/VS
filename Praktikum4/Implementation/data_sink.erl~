-module(data_sink).
-export([start/1]).


start(LogFileName) ->
	receive
		{data, _} ->
			start(LogFileName)
	end.