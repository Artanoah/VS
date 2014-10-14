-module(test).
-export([double/1, revert/1, flatten/1]).

double(X) ->
	2 * X.

revert([]) -> 
	[];
revert([X|XS]) ->
	revert(XS) ++ [X].

flatten([]) ->
	[];
flatten([[X]|XSS]) ->
	flatten([X]) ++ flatten(XSS);
flatten([X|XS]) ->
	[X | flatten(XS)].