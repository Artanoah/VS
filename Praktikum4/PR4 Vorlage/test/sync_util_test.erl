-module(sync_util_test).
-include_lib("eunit/include/eunit.hrl").

-define(DUMMY_TIME, 1418288980219).

current_time_test() ->
	Time = ?DUMMY_TIME,
	SyncManager = spawn(fun() ->
		receive
			{get_current_time, PID} ->
				PID ! {current_time, Time}
		end
	end),
	Time = sync_util:current_time(SyncManager),
	ok.

calculate_frame_test() ->
	1418288980 = sync_util:calculate_frame(?DUMMY_TIME),
	ok.

current_slot_test() ->
	1 = sync_util:current_slot(39),
	2 = sync_util:current_slot(40),
	6 = sync_util:current_slot(?DUMMY_TIME),
	25 = sync_util:current_slot(999),
	ok.

time_till_next_slot_test() ->
	40 = sync_util:time_till_next_slot(0),
	21 = sync_util:time_till_next_slot(?DUMMY_TIME),
	ok.

current_frame_time_test() ->
	219 = sync_util:current_frame_time(?DUMMY_TIME),
	ok.

time_till_next_frame_test() ->
	1000 = sync_util:time_till_next_frame(0),
	1 = sync_util:time_till_next_frame(999),
	781 = sync_util:time_till_next_frame(?DUMMY_TIME),
	ok.

time_till_transmission_slot_test() ->
	-10 = sync_util:time_till_transmission_slot(20, 1),
	31 = sync_util:time_till_transmission_slot(?DUMMY_TIME, 7),
	969 = sync_util:time_till_transmission_slot(1, 25),
	-29 = sync_util:time_till_transmission_slot(999, 25),
	ok.
