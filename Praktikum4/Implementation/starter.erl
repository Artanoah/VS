-module(starter).
-export([start/6]).

start(0, _, _, _, _, _) ->
	started;

start(Number, InterfaceName, IP, Port, StationType, Offset) ->
	station:start(InterfaceName, IP, Port, StationType, Offset),
	start(Number-1, InterfaceName, IP, Port, StationType, Offset).