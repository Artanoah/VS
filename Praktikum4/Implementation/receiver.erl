-module(receiver).
-export([start/6]).


start(DataSink, SlotManager, TimeMaster, Interface, IP, Port) ->
	spawn(udp_receiver, start, [self(), TimeMaster, Interface, IP, Port]),
	loop(DataSink, SlotManager, TimeMaster, []).

loop(DataSink, SlotManager, TimeMaster, Messages) ->
	receive
		{udp_message, {ok, {_, _, Paket}}} ->
			% UDP-Nachricht erfolgreich empfangen
			OurTimestamp = util:get_time_master_time(TimeMaster),

			<<BinStationType:1/binary,
			  BinPayload:24/binary,
			  BinSlot:8/integer,
			  BinForeignTimestamp:64/integer-big>> = Paket,
					
			StationType = binary_to_list(BinStationType),
			Payload = binary_to_list(BinPayload),
			Slot = BinSlot,
			ForeignTimestamp = BinForeignTimestamp,
			
			loop(DataSink, SlotManager, TimeMaster, [{StationType, Payload, Slot, ForeignTimestamp, OurTimestamp} | Messages]);

		{slot_passed} ->
			case length(Messages) of
				0 ->
					SlotManager ! {no_messages},
					loop(DataSink, SlotManager, TimeMaster, []);

				1 ->
					[{StationType, Payload, Slot, ForeignTimestamp, OurTimestamp} | _] = Messages,
					SlotManager ! {slot_reservation, Slot - 1},
					DataSink    ! {data, Payload},

					if StationType == "A" ->
						TimeMaster  ! {new_message, ForeignTimestamp, OurTimestamp};
					    true ->
						ok
					end,

					loop(DataSink, SlotManager, TimeMaster, []);

				_ -> 
					SlotManager ! {collision_detected},
					[{_, _, _, ForeignTimestamp1, OurTimestamp1}, {_, _, _, ForeignTimestamp2, OurTimestamp2} | _] = Messages,
					io:fwrite("Our1: " ++ integer_to_list(OurTimestamp1) ++ " Foreign1: " ++ integer_to_list(ForeignTimestamp1) ++ "~n" ++
						  "Our2: " ++ integer_to_list(OurTimestamp2) ++ " Foreign2: " ++ integer_to_list(ForeignTimestamp2) ++ "~n"),
					loop(DataSink, SlotManager, TimeMaster, [])
			end
	end.