-module(slot_manager_test).
-include_lib("eunit/include/eunit.hrl").

create_free_list_test() ->
	[1, 2, 3] = slot_manager:create_free_list(3).

select_reservable_slot_test() ->
	42 = slot_manager:select_reservable_slot([42]),
	List = [1, 2, 3],
	true = lists:member(slot_manager:select_reservable_slot(List), List),
	ok.

