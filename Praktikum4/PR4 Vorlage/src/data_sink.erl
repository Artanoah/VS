-module (data_sink).
-export ([start/0]).

-define(LOG_FILE_PATH, "/tmp/").

start () ->
	io:format ("data_sink: starting logging process."),
	spawn (fun () -> loop () end).

loop () ->
	receive
		{data, Data} -> 
			on (data, {Data}),
			loop ()
	end.

on (data, {Data}) ->
	Text = io_lib:format ("~s\n", [Data]),
	FilePath = ?LOG_FILE_PATH ++ lists:sublist (Data, 1, 10) ++ ".log",
	file:write_file (FilePath, [Text], [append]).
