-module(nameservice).
-export([start/0]).

%% Namensdienst wird global bei allen Erlang nodes unter nameservice registriert.
start() ->
	{ok, HostName} = inet:gethostname(),
	Datei = lists:concat(["nameservice@",HostName,".log"]),	
	ServerPid = spawn(fun() -> loop(dict:new(),Datei) end),
	global:register_name(nameservice,ServerPid),
    Zeit = lists:concat(["Nameservice Startzeit: ",util:timeMilliSecond()]),
	Inhalt = lists:concat([Zeit," mit PID ",pid_to_list(ServerPid)," registriert mit Namen 'nameservice'.\r\n"]),
	util:logging(Datei,Inhalt).

loop(Dict,Datei) ->
	receive
		{From,{lookup,Name}} when is_pid(From) and is_atom(Name) ->
			Inhalt1 = lists:concat(["lookup um ",util:timeMilliSecond()," von ",pid_to_list(From),":"]),
			case dict:find(Name,Dict) of
				{ok,Node} ->
					Inhalt = lists:concat([Inhalt1,"{",Name,",",Node,"}.\n"]),
					From ! {pin,{Name,Node}};
				error ->
				    SName = util:to_String(Name),
					Inhalt = lists:concat([Inhalt1,"not_found:",SName,".\n"]),
					From ! not_found
			end,		
			util:logging(Datei,Inhalt),
			
			loop(Dict,Datei);
		{From,{bind,Name,Node}} when is_pid(From) and is_atom(Name) ->
		    SName = util:to_String(Name),
			Inhalt1 = lists:concat(["bind um ",util:timeMilliSecond()," von ",pid_to_list(From)," (",SName,"):"]),
			case dict:find(Name,Dict) of
				{ok,Node} ->
					Inhalt = lists:concat([Inhalt1,"in_use ({",SName,",",Node,"}.\n"]),
					DictNew = Dict,
					From ! in_use;
				error ->
					Inhalt = lists:concat([Inhalt1,"{",SName,",",Node,"}.\n"]),
					DictNew = dict:store(Name, Node, Dict),
					From ! ok
			end,		
			util:logging(Datei,Inhalt),
			
			loop(DictNew,Datei);
		{From,{rebind,Name,Node}} when is_pid(From) and is_atom(Name) ->
		    SName = util:to_String(Name),
			DictNew = dict:store(Name, Node, Dict),
			Inhalt = lists:concat(["rebind um ",util:timeMilliSecond()," von ",pid_to_list(From),": {",SName,",",Node,"}.\n"]),
			From ! ok,
			util:logging(Datei,Inhalt),
			
			loop(DictNew,Datei);
		{From,{unbind,Name}} when is_pid(From) and is_atom(Name) ->
		    SName = util:to_String(Name),
			DictNew = dict:erase(Name, Dict),
			Inhalt = lists:concat(["unbind um ",util:timeMilliSecond()," von ",pid_to_list(From),":",SName,".\n"]),
			From ! ok,
			util:logging(Datei,Inhalt),

			loop(DictNew,Datei);
		{From,listall} when is_pid(From) ->
			Inhalt = lists:concat(["listall um ",util:timeMilliSecond()," von ",pid_to_list(From),".\n"]),
			List = dict:to_list(Dict),
			From ! {list,List},
			util:logging(Datei,Inhalt),

			loop(Dict,Datei);
		{From,reset} when is_pid(From) ->
			Inhalt = lists:concat(["reset um ",util:timeMilliSecond()," von ",pid_to_list(From),".\n"]),
			lib:flush_receive(),
			From ! ok,
			util:logging(Datei,Inhalt),

			loop(dict:new(),Datei);
		{From,kill} when is_pid(From) ->
			Inhalt = lists:concat(["kill um ",util:timeMilliSecond()," von ",pid_to_list(From),".\n"]),
			From ! ok,
			util:logging(Datei,Inhalt);
		Any -> 
		    Inhalt = "in loop unerwartete Nachricht erhalten."++util:to_String(Any)++"\r\n",
			util:logging(Datei,Inhalt),	

			loop(Dict,Datei)			
	end.