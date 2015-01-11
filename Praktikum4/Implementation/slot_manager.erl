-module(slot_manager).
-export([start/1]).


start(TimeMaster) ->
	receive
		{missing_references, Sender, Receiver} ->
			util:console_out("Slot-Manager: Got References - Waiting for next Frame"),
			ok = wait_until_next_frame(TimeMaster),
			self() ! {slot_ended},
			loop(TimeMaster, Sender, Receiver, [], -1, -1);

		Message ->
			util:console_out("Slot-Manager: Unknown Message Received"),
			self() ! Message,
			start(TimeMaster)
	end.


loop(TimeMaster, Sender, Receiver, ReservedSlotList, ReservedSlot, LastReservedSlot) ->
	receive
		
		{get_reservable_slot, PID} ->
			ReservableSlot = get_random_free_slot(ReservedSlotList),
			PID ! {reservable_slot, ReservableSlot},
			%util:console_out("Slot-Manager: Someone requested a slot to reserve - reserving Slot no " ++ integer_to_list(ReservableSlot)),
			loop(TimeMaster, Sender, Receiver, ReservedSlotList, ReservableSlot, LastReservedSlot);

		{slot_missed} ->
			util:console_out("Slot-Manager: Sender missed his slot"),
			loop(TimeMaster, Sender, Receiver, ReservedSlotList, -1, LastReservedSlot);

		{slot_ended} ->
			%NewSlot = SlotCounter + 1,
			
			% Wenn ein Frame zu Ende ist
			case is_new_frame(TimeMaster) of
				true ->
					Receiver ! {slot_passed},
	
					{NewTimeMaster, NewSender, NewReceiver, NewReservedSlotList, NewReservedSlot, _} = receive_receiver_answer(TimeMaster, Sender, Receiver, ReservedSlotList, ReservedSlot, LastReservedSlot),
					
					NewTimeMaster ! {sync},
					% Wenn ein Slot reserviert wurde
					case NewReservedSlot >= 0 of
						true ->
							SlotToUse = NewReservedSlot,
							util:console_out("Slot-Manager: Slot reserved: " ++ integer_to_list(SlotToUse));
	
						false ->
							SlotToUse = get_random_free_slot(NewReservedSlotList),
							util:console_out("Slot-Manager: Slot random: " ++ integer_to_list(SlotToUse))
					end,
					Time = util:get_time_master_time(TimeMaster),
					FrameBeginTime = Time - (Time rem 1000),
					Sender ! {new_timer, SlotToUse * 40 + 10, {FrameBeginTime + SlotToUse * 40, FrameBeginTime + SlotToUse * 40 + 39}},
					set_slot_timer(Time),
					
					io:format("slot_manager: Current Slot-Reservations = ~p~n", [NewReservedSlotList]),
					%util:console_out("slot_manager: Current Slot-Reservations = " ++ ReservedSlotList),
					
					loop(NewTimeMaster, NewSender, NewReceiver, [], -1, NewReservedSlot);
				
				false ->
					Time = util:get_time_master_time(TimeMaster),
					set_slot_timer(Time),
					Receiver ! {slot_passed},
					{NewTimeMaster, NewSender, NewReceiver, NewReservedSlotList, NewReservedSlot, NewLastReservedSlot} = receive_receiver_answer(TimeMaster, Sender, Receiver, ReservedSlotList, ReservedSlot, LastReservedSlot),
					loop(NewTimeMaster, NewSender, NewReceiver, NewReservedSlotList, NewReservedSlot, NewLastReservedSlot)
			end;

		_ ->
			util:console_out("Slot-Manager: Unknown Message received"),
			loop(TimeMaster, Sender, Receiver, ReservedSlotList, ReservedSlot, LastReservedSlot)

		end.
			
				

wait_until_next_frame(TimeMaster) ->
	Time = util:get_time_master_time(TimeMaster),
	erlang:send_after(time_until_frame(Time), self(), {let_the_frames_begin}),
	util:console_out("Slot-Manager: Waiting for next frame - " ++ integer_to_list(time_until_frame(Time))),
	receive
		{let_the_frames_begin} ->
		  ok
	end.
			

time_until_frame(Time) ->
	1000 - (Time rem 1000).


get_current_slot(Time) ->
	(Time rem 1000) div 40.



set_slot_timer(Time) ->
	% (SlotDauer - (Zeitpunkt mod SlotDauer)) + ExtraWartezeit
	TimeToWait = (40 - (Time rem 40)) + 5,
	erlang:send_after(TimeToWait, self(), {slot_ended}).


get_random_free_slot(SlotList) ->
	FreeSlots = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24] -- SlotList,
	Index = util:random(length(FreeSlots)),
	lists:nth(Index, FreeSlots).


is_new_frame(TimeMaster) ->
	Time = util:get_time_master_time(TimeMaster),
	(Time rem 1000) =< 40.
	
	
receive_receiver_answer(TimeMaster, Sender, Receiver, ReservedSlotList, ReservedSlot, LastReservedSlot) ->
	receive
		{no_messages} ->
			% util:console_out("No Messages received"),
			{TimeMaster, Sender, Receiver, ReservedSlotList, ReservedSlot, LastReservedSlot};

		{slot_reservation, Slot} ->
			%util:console_out("Slot-Manager: Someone reserved the slot no - " ++ integer_to_list(Slot)),
			case (Slot == ReservedSlot) and (lists:member(Slot, ReservedSlotList)) of
				true ->
					{TimeMaster, Sender, Receiver, ReservedSlotList, -1, LastReservedSlot};
				false ->
					{TimeMaster, Sender, Receiver, [Slot | ReservedSlotList], ReservedSlot, LastReservedSlot}
			end;

		{collision_detected} ->
			Time = util:get_time_master_time(TimeMaster),
			CurrentSlot = get_current_slot(Time) - 1,
			
			if 	CurrentSlot < 0 ->
					CorrectedSlot = 24;
				
				CurrentSlot >= 0 ->
					CorrectedSlot = CurrentSlot
			end,

			if
				CorrectedSlot == LastReservedSlot ->
					%util:console_out("slot_manager: Collision detected; own reservation deleted " ++ integer_to_list(ReservedSlot)),
					{TimeMaster, Sender, Receiver, ReservedSlotList, -1, LastReservedSlot};
							
				true ->
					util:console_out("############## Slot-Manager: Collision detected ##############"),
					{TimeMaster, Sender, Receiver, ReservedSlotList, ReservedSlot, LastReservedSlot}
			end
	end. 
