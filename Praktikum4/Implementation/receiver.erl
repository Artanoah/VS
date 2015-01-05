-module(receiver).
-export([start/6]).


start(DataSink, SlotManager, TimeMaster, Interface, IP, Port) ->
	spawn(udp_receiver, start, [self(), TimeMaster, Interface, IP, Port]),
	loop(DataSink, SlotManager, TimeMaster, []).

loop(DataSink, SlotManager, TimeMaster, Messages) ->
	receive
		{udp_message, StationType, Payload, Slot, ForeignTimestamp, OurTimestamp} ->
			loop(DataSink, SlotManager, TimeMaster, [{StationType, Payload, Slot, ForeignTimestamp, OurTimestamp} | Messages]);

		{slot_passed} ->
			case length(Messages) of
				0 ->
					SlotManager ! {no_messages},
					loop(DataSink, SlotManager, TimeMaster, []);

				1 ->
					[{StationType, Payload, Slot, ForeignTimestamp, OurTimestamp} | _] = Messages,
					SlotManager ! {slot_reservation, Slot},
					DataSink    ! {data, Payload},

					if StationType == "A" ->
						TimeMaster  ! {new_message, ForeignTimestamp, OurTimestamp}
					end,

					loop(DataSink, SlotManager, TimeMaster, []);

				_ -> 
					SlotManager ! {collision_detected},
					loop(DataSink, SlotManager, TimeMaster, [])
			end
	end.