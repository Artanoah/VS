-module(debug).
-export([print/1, print/2]).

print(Text) ->
	print(Text, []).
print(Text, Args) ->
	io:format(user, Text, Args).
