-module (sync_util).
-export ([
	current_time/1,
	current_frame_time/1,
	time_till_next_slot/1,
	time_till_next_frame/1,
	time_till_transmission_slot/2,
	current_slot/1,
	calculate_frame/1
]).

-define (SLOT_LENGTH_MS, 40).
-define (FRAME_LENGTH_MS, 1000).

current_time (SyncManager) ->
	SyncManager ! {get_current_time, self ()},
	receive
		{current_time, Time} ->
			Time
	end.

% calculates time to wait until next slot
time_till_next_slot (CurrentTime) ->
	slot_time (current_slot (CurrentTime)) - current_frame_time (CurrentTime).

% calculates the time to wait between now (CurrentTime) and the given slot
% in the current frame
time_till_transmission_slot (CurrentTime, TransmissionSlot) ->
	RemainingSlotTime = time_till_next_slot(CurrentTime),
	TimeFromNextSlotTillTransmissionSlot = slot_time (TransmissionSlot)
		- slot_time (current_slot (CurrentTime) + 1),
	Offset = ?SLOT_LENGTH_MS div 4,
	RemainingSlotTime + TimeFromNextSlotTillTransmissionSlot + Offset.

% get the time in milliseconds until the next frame starts
time_till_next_frame (CurrentTime) ->
	?FRAME_LENGTH_MS - current_frame_time (CurrentTime).

% slot number times the lenght of a slot
slot_time (Slot) ->
	Slot * ?SLOT_LENGTH_MS.

% get the current slow depending on given time
current_slot (CurrentTime) ->
	current_frame_time (CurrentTime) div ?SLOT_LENGTH_MS + 1.

%
calculate_frame (Time) ->
	Time div 1000.

% result is a time between 0 and FRAME_LENGTH_MS
% representing the time relative to the current frame
current_frame_time (CurrentTime) ->
	CurrentTime rem ?FRAME_LENGTH_MS.
