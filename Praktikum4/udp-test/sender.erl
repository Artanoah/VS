-module(sender).
-export([start/4]).


start(ID, Interface, IP, Port) ->
	Socket = util:openSe(Interface, Port),
	loop(ID, Socket).


loop(ID, Socket, IP, Port) ->
	receive
		{start_send} ->
			util:wait_random_ms(500),
			Packet = <<ID:8/integer>>,
			ok = gen_udp:send(Socket, IP, Port, Paket),
			loop(ID, Socket, IP, Port)
	end.