-module (slot_manager).
-export ([start/1]).

-define (SLOTS, 25).

-record (ctx, {
	sync_mgr_pid,
	sender_pid,
	receiver_pid,
	free_slots,
	reserved_slot = -1,
	slot_timer = undefined,
	transmission_slot
}).

start (SyncManagerPID) ->
	Context = #ctx {
		sync_mgr_pid = SyncManagerPID
	},
	spawn (fun () -> init (Context) end).

% intial state
init (Context)
	when Context#ctx.sender_pid /= undefined,
	     Context#ctx.receiver_pid /= undefined ->
	% do some further initialization
	T = sync_util:current_time (Context#ctx.sync_mgr_pid),
	random:seed (now ()),
	ready (reset_free_list (restart_slot_timer (Context, T)));
init (Context) ->
	receive
		{set_receiver, Receiver} ->
			NewContext = Context#ctx {
				receiver_pid = Receiver
			};
		{set_sender, Sender} ->
			NewContext = Context#ctx {
				sender_pid = Sender
			}
	end,
	init (NewContext).

% receive loop
ready (Context) ->
	receive
		{get_reservable_slot} ->
			NewContext = on (get_reservable_slot, Context, {}),
			ready (NewContext);
		{slot_missed} ->
			NewContext = on (slot_missed, Context, {}),
			ready (NewContext);
		{slot_passed} ->
			NewContext = on (slot_passed, Context, {}),
			ready (NewContext)
	end.

% remove given slot from lists of free slots
on (slot_reservation, Context, {Slot}) ->
	do_reservation (Context, Slot, Context#ctx.reserved_slot);
% reset slot resevation for next frame
on (collision_detected, Context, {}) ->
	CurrentTime = sync_util:current_time (Context#ctx.sync_mgr_pid),
	LastSlot = sync_util:current_slot (CurrentTime) - 1,
	collision_with_own_message (Context, Context#ctx.transmission_slot, LastSlot);
% reserve the next slot to send in
on (get_reservable_slot, Context, {}) ->
	NextSlot = select_reservable_slot (Context#ctx.free_slots),
	Context#ctx.sender_pid ! {reservable_slot, NextSlot},
	set_reservation (remove_from_free_list (Context, NextSlot), NextSlot);
on (slot_missed, Context, {}) ->
	set_reservation (Context, -1);
on (slot_passed, Context, {}) ->
	Context#ctx.receiver_pid ! {slot_passed},
	receive
		{no_messages} ->
			NewContext = Context;
		{slot_reservation, Slot} ->
			NewContext = on (slot_reservation, Context, {Slot});
		{collision_detected} ->
			NewContext = on (collision_detected, Context, {})
	end,
	T = sync_util:current_time (NewContext#ctx.sync_mgr_pid),
	CurrentSlot = sync_util:current_slot (T),
	handle_frame_passed (NewContext, T, CurrentSlot).

% do slot reservation depending on our previous reservation not beeing reserved
% by the recently received message
do_reservation (Context, Slot, Slot) ->
	% reset
	T = sync_util:current_time (Context#ctx.sync_mgr_pid),
	LastSlot = sync_util:current_slot (T) - 1,
	check_if_own_reservation (Context, LastSlot, Context#ctx.transmission_slot);
do_reservation (Context, Slot, _OtherSlot) ->
	remove_from_free_list (Context, Slot).

check_if_own_reservation (Context, 0, TransmissionSlot) ->
	check_if_own_reservation (Context, 25, TransmissionSlot);
check_if_own_reservation (Context, TransmissionSlot, TransmissionSlot) ->
	Context;
check_if_own_reservation (Context, _LastSlot, _TransmissionSlot) ->
	set_reservation (Context, -1).


% collision handling
collision_with_own_message (Context, Slot, 0) ->
	collision_with_own_message(Context, Slot, 25);
collision_with_own_message (Context, Slot, Slot) ->
	% react to collision
	set_reservation (readd_reserved_slot (Context), -1);
collision_with_own_message (Context, _OtherSlot, _Slot) ->
	Context.

readd_reserved_slot(Context) when Context#ctx.reserved_slot == -1 ->
	Context;
readd_reserved_slot(Context) ->
	Context#ctx {
		free_slots = [Context#ctx.reserved_slot|Context#ctx.free_slots]
	}.

handle_frame_passed (Context, PreSyncT, 1) ->
	PreSyncFrame = sync_util:calculate_frame (PreSyncT),
	Context#ctx.sync_mgr_pid ! {sync},
	Context#ctx.sync_mgr_pid ! {reset},
	PostSyncT = sync_util:current_time (Context#ctx.sync_mgr_pid),
	PostSyncFrame = sync_util:calculate_frame (PostSyncT),
	restart_slot_timer(
	  prepare_frame(Context, PreSyncFrame, PostSyncFrame, PostSyncT),
	  PostSyncT
	);
handle_frame_passed (Context, T, _Slot) ->
	restart_slot_timer(Context, T).

prepare_frame(Context, PreSyncFrame, PostSyncFrame, _)
	when PreSyncFrame > PostSyncFrame ->
	% we have been reset back in time
	Context;
prepare_frame(Context, _PreSyncFrame, _PostSyncFrame, PostSyncT) ->
	PostSyncSlot = sync_util:current_slot(PostSyncT),
	TransmissionSlot = get_transmission_slot(Context, PostSyncSlot),
	notify_sender(Context, TransmissionSlot, PostSyncT),
	%Context#ctx.sync_mgr_pid ! {reset},
	set_transmission_slot (set_reservation(reset_free_list(Context), -1), TransmissionSlot).

get_transmission_slot(Context, _) when Context#ctx.reserved_slot > 0 ->
	get_reservation(Context);
get_transmission_slot(Context, PostSyncSlot) ->
	FreeSlots = [S || S <- Context#ctx.free_slots, S >= PostSyncSlot],
	select_reservable_slot(FreeSlots).

notify_sender(_Context, -1, _T) ->
	ok;
% notify the sender about its wait time
notify_sender(Context, TransmissionSlot, T) ->
	% calculate time to wait for sender
	TimeToWaitForSender = sync_util:time_till_transmission_slot (T, TransmissionSlot),
	% send wait time to sender
	Context#ctx.sender_pid ! {new_timer,
		TimeToWaitForSender
	}.

% set_transmission_slot (Context, Slot)
set_transmission_slot (Context, Slot) ->
	Context#ctx {
		transmission_slot = Slot
	}.

% restarts the slot timer
restart_slot_timer (Context, CurrentTime) ->
	Context#ctx {
		slot_timer = reset_timer (Context#ctx.slot_timer,
			sync_util:time_till_next_slot (CurrentTime),
			{slot_passed}
		)
	}.

% marks given slot as reserved
set_reservation (Context, Slot) ->
	Context#ctx {
		reserved_slot = Slot
	}.

% get reserved slot for the next frame.
% if there is no reservation, choose one randomly.
select_reservable_slot ([]) ->
	-1;
select_reservable_slot (FreeSlots) ->
	% get number of free slots
	NFreeSlots = length (FreeSlots),
	% choose one randomly
	Index = random:uniform (NFreeSlots),
	% retrieve it from the list
	lists:nth (Index, FreeSlots).

get_reservation (Context) ->
	Context#ctx.reserved_slot.

% resets the list of free slots
reset_free_list (Context) ->
	Context#ctx {
		free_slots = create_free_list (?SLOTS)
	}.
create_free_list (NumberOfSlots) ->
	create_free_list ([], NumberOfSlots, NumberOfSlots).
create_free_list (List, _NumberOfSlots, 0) ->
	List;
create_free_list (List, NumberOfSlots, CurrentSlot) ->
	create_free_list ([CurrentSlot | List], NumberOfSlots, CurrentSlot-1).

% deletes slot from free list
remove_from_free_list (Context, Slot) ->
	Context#ctx {
		free_slots = lists:delete (Slot, Context#ctx.free_slots)
	}.

% resets the timer. if it has been set befor,
% cancel it befor resitting.
reset_timer (undefined, WaitTime, Message) ->
	erlang:send_after (WaitTime, self(), Message);
reset_timer (Timer, WaitTime, Message) ->
	erlang:cancel_timer (Timer),
	erlang:send_after (WaitTime, self(), Message).
