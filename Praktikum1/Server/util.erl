-module(util).
-export([time_in_ms/0, head/1, tail/1]).


time_in_ms() ->
	time_in_ms_helper(os:timestamp()).

time_in_ms_helper({MegS, S, MS}) ->
	((MegS * 1000000 + S) * 1000000 + MS) / 1000.

head([]) ->
	[];

head([X | _]) ->
	X.

tail([]) ->
	[];

tails([_ | XS]) ->
	XS.