-module(sender_test).
-include_lib("eunit/include/eunit.hrl").

sender_test() ->
	ExpectedPayload = [116,101,97,109,32,48,51,45,49,48,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	ExpectedStationType = "A",
	ExpectedSlot = 5,

	{ok, InterfaceIP} = inet:parse_address("127.0.0.1"),
	{ok, MultiIP} = inet:parse_address("225.10.1.2"),
	Port = 16000,

	udp_proc:start(self(), InterfaceIP, MultiIP, Port),

	SyncManager = sync_manager:start(0, "A"),
	Sender = sender:start(
		SyncManager,
		self(),
		InterfaceIP,
		MultiIP,
		Port,
		ExpectedStationType
	),
	Sender ! {payload, ExpectedPayload},
	Sender ! {new_timer, 10},
	receive {get_reservable_slot} ->
		Sender ! {reservable_slot, ExpectedSlot}
	end,
	receive {message, Payload, StationType, Slot, _Time} ->
		ExpectedPayload = Payload,
		ExpectedStationType = StationType,
		ExpectedSlot = Slot
	end,
	ok.

sender_slot_missed_test() ->
	{ok, InterfaceIP} = inet:parse_address("127.0.0.1"),
	{ok, MultiIP} = inet:parse_address("225.10.1.2"),
	Port = 16000,
	StationType = "A",

	ExpectedPayload = [116,101,97,109,32,48,51,45,49,48,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	ExpectedSlot = 5,

	SyncManager = sync_manager:start(0, StationType),
	Sender = sender:start(
		SyncManager,
		self(),
		InterfaceIP,
		MultiIP,
		Port,
		StationType
	),
	Sender ! {payload, ExpectedPayload},
	Sender ! {new_timer, -25},
	receive {get_reservable_slot} ->
		Sender ! {reservable_slot, ExpectedSlot}
	end,
	receive
		{slot_missed} ->
			ok
	end,
	ok.
