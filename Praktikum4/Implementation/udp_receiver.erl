-module(udp_receiver).
-export([start/5]).


start(Receiver, TimeMaster, Interface, IP, Port) ->
	Socket = util:openRec(IP, Interface, Port),
	gen_udp:controlling_process(Socket, self()),
	loop(Receiver, TimeMaster, Socket).

loop(Receiver, TimeMaster, Socket) ->
	case gen_udp:recv(Socket, 0) of
		% Fehler beim Empfangen
		{error, Reason} ->
			util:console_out("Error while receiving UDP-Message: " ++ Reason);

		% UDP-Nachricht erfolgreich empfangen
		{ok, {_, _, Paket}} ->
			OurTimestamp = util:time_master_time(TimeMaster),

			<<StationType:1/binary,
			  Payload:24/binary,
			  Slot:8/integer,
			  ForeignTimestamp:64/integer-big>> = Paket,

			Receiver ! {udp_message, binary_to_list(StationType), binary_to_list(Payload), Slot, OurTimestamp, ForeignTimestamp},
			loop(Receiver, TimeMaster, Socket)
	end.
