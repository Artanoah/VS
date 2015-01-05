-module(slot_manager).
-export([start/1]).


start(TimeMaster) ->
	receive
		{missing_references, Sender, Receiver} ->
			util:console_out("Got References - Waiting for next Frame"),
			wait_until_next_frame(TimeMaster),
			self() ! {slot_ended},
			loop(TimeMaster, Sender, Receiver, 0, [], -1, -1);

		Message ->
			util:console_out("Unknown Message Received"),
			self() ! Message,
			start(TimeMaster)
	end.


loop(TimeMaster, Sender, Receiver, SlotCounter, ReservedSlotList, ReservedSlot, LastReservedSlot) ->
	receive
		{no_messages} ->
			util:console_out("No Messages received"),
			loop(TimeMaster, Sender, Receiver, SlotCounter, ReservedSlotList, ReservedSlot, LastReservedSlot);

		{slot_reservation, Slot} ->
			util:console_out("Someone reserved a slot"),
			loop(TimeMaster, Sender, Receiver, SlotCounter, [Slot, ReservedSlotList], ReservedSlot, LastReservedSlot);

		{collision_detected} ->
			util:console_out("Collision detected"),
			Time = util:get_time_master_time(TimeMaster),
			CurrentSlot = get_current_slot(Time),

			if
				CurrentSlot == LastReservedSlot ->
					loop(TimeMaster, Sender, Receiver, SlotCounter, ReservedSlotList, -1, LastReservedSlot)
			end;

		{get_reservable_slot, PID} ->
			ReservableSlot = get_reservable_slot(ReservedSlotList),
			PID ! {reservable_slot, ReservableSlot},
			loop(TimeMaster, Sender, Receiver, SlotCounter, ReservedSlotList, ReservableSlot, LastReservedSlot);

		{slot_missed} ->
			loop(TimeMaster, Sender, Receiver, SlotCounter, ReservedSlotList, -1, LastReservedSlot);

		{slot_ended} ->
			util:console_out("Slot Ended"),
			NewSlot = SlotCounter + 1,
			
			% Wenn ein Frame zu Ende ist
			case NewSlot == 25 of
				true ->
					TimeMaster ! {sync},
					% Wenn ein Slot reserviert wurde
					case ReservedSlot >= 0 of
						true ->
							SlotToUse = ReservedSlot;
	
						false ->
							SlotToUse = get_random_free_slot(ReservedSlotList)
					end,
					TempTime = util:get_time_master_time(TimeMaster),
					Sender ! {new_timer, SlotToUse * 40, {TempTime + SlotToUse * 40, TempTime + SlotToUse * 40 + 40}},
					
					Time = util:get_time_master_time(TimeMaster),
					set_slot_timer(Time),
					Receiver ! {slot_passed},
					loop(TimeMaster, Sender, Receiver, 0, [], -1, ReservedSlot);
				
				false ->
					Time = util:get_time_master_time(TimeMaster),
					set_slot_timer(Time),
					Receiver ! {slot_passed},
					loop(TimeMaster, Sender, Receiver, NewSlot, ReservedSlotList, -1, ReservedSlot)
			end;

		_ ->
			util:console_out("Unknown Message received"),
			loop(TimeMaster, Sender, Receiver, SlotCounter, ReservedSlotList, ReservedSlot, LastReservedSlot)

		end.
			
				

wait_until_next_frame(TimeMaster) ->
	erlang:start_timer(time_until_frame(util:get_time_master_time(TimeMaster)), self(), {let_the_frames_begin}),
	receive
		{let_the_frames_begin} ->
			util:console_out("Frame ended")
	end.
			

time_until_frame(Time) ->
	1000 - (Time rem 1000).


get_current_slot(Time) ->
	(Time rem 1000) div 40.


get_reservable_slot(SlotList) ->
	get_reservable_slot_helper(SlotList, 0).

get_reservable_slot_helper(SlotList, Counter) ->
	case lists:member(Counter, SlotList) of
		false ->
			Counter;
		true ->
			get_reservable_slot_helper(SlotList, Counter + 1)
	end.


set_slot_timer(Time) ->
	TimeToWait = 40 - (Time rem 40),
	erlang:send_after(TimeToWait, self(), {slot_ended}).


get_random_free_slot(SlotList) ->
	FreeSlots = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24] -- SlotList,
	Index = random:uniform(length(FreeSlots)),
	list:nth(Index, FreeSlots).