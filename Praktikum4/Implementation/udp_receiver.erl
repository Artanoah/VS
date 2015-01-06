-module(udp_receiver).
-export([start/5]).


start(Receiver, TimeMaster, Interface, IP, Port) ->
	Socket = util:openRec(IP, Interface, Port),
	gen_udp:controlling_process(Socket, self()),
	util:console_out("udp_receiver: started"),
	inet:setopts(Socket, [{broadcast, true}]),
	loop(Receiver, TimeMaster, Socket).

loop(Receiver, TimeMaster, Socket) ->
	Message = gen_udp:recv(Socket, 0),
	case Message of
		% Fehler beim Empfangen
		{error, Reason} ->
			util:console_out("udp_receiver: Error while receiving UDP-Message");

		% UDP-Nachricht erfolgreich empfangen
		{ok, {_, _, Paket}} ->
			util:console_out("udp_receiver: UDP-Paket received"),
			OurTimestamp = util:get_time_master_time(TimeMaster),

			<<StationType:1/binary,
			  Payload:24/binary,
			  Slot:8/integer,
			  ForeignTimestamp:64/integer-big>> = Paket,

			Receiver ! {udp_message, binary_to_list(StationType), binary_to_list(Payload), Slot, OurTimestamp, ForeignTimestamp};
			
		_ ->
		  util:console_out("udp_receiver: unknown packet")
	end,
	
	loop(Receiver, TimeMaster, Socket).
