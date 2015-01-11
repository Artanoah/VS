-module(udp_receiver).
-export([start/5]).


start(Receiver, TimeMaster, Interface, IP, Port) ->
	Socket = util:openRec(IP, Interface, Port),
	gen_udp:controlling_process(Socket, self()),
	util:console_out("udp_receiver: started"),
	%inet:setopts(Socket, [{broadcast, true}]),
	loop(Receiver, TimeMaster, Socket).

loop(Receiver, TimeMaster, Socket) ->
	Message = gen_udp:recv(Socket, 0),
	Receiver ! {udp_message, Message},
	loop(Receiver, TimeMaster, Socket).
