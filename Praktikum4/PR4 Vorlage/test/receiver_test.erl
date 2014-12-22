-module(receiver_test).
-include_lib("eunit/include/eunit.hrl").

receiver_one_message_test() ->
	{ok, InterfaceIP} = inet:parse_address("127.0.0.1"),
	{ok, MultiIP} = inet:parse_address("225.10.1.2"),
	Port = 16000,

	Receiver = receiver:start(
		self(),
		self(),
		self(),
		InterfaceIP,
		MultiIP,
		Port
	),
	
	Payload = "foo",
	StationType = "A",
	Slot = 5,
	Time = 8042,

	Receiver ! {message, Payload, StationType, Slot, Time},
	receive
		{get_current_time, PID} ->
			PID ! {current_time, Time}
	end,
	Receiver ! {slot_passed},
	receive
		{slot_reservation, ReservedSlot} ->
			Slot = ReservedSlot
	end,
	receive
		{data, ReceivedPayload} ->
			Payload = ReceivedPayload
	end,
	receive
		{new_message, ReceivedStationType, ReceivedTime, _LocalTime} ->
			StationType = ReceivedStationType,
			Time = ReceivedTime
	end,
	ok.

receiver_no_messages_test() ->
	{ok, InterfaceIP} = inet:parse_address("127.0.0.1"),
	{ok, MultiIP} = inet:parse_address("225.10.1.2"),
	Port = 16000,

	Receiver = receiver:start(
		self(),
		self(),
		self(),
		InterfaceIP,
		MultiIP,
		Port
	),
	
	Receiver ! {slot_passed},
	receive
		{no_messages} ->
			ok
	end,
	ok.
receiver_collision_test() ->
	{ok, InterfaceIP} = inet:parse_address("127.0.0.1"),
	{ok, MultiIP} = inet:parse_address("225.10.1.2"),
	Port = 16000,

	Receiver = receiver:start(
		self(),
		self(),
		self(),
		InterfaceIP,
		MultiIP,
		Port
	),
	
	Payload = "foo",
	StationType = "A",
	Slot = 5,
	Time = 8042,

	Receiver ! {message, Payload, StationType, Slot, Time},
	receive
		{get_current_time, PID1} ->
			PID1 ! {current_time, Time}
	end,
	Receiver ! {message, Payload, StationType, Slot, Time},
	receive
		{get_current_time, PID} ->
			PID ! {current_time, Time}
	end,
	Receiver ! {slot_passed},
	receive
		{collision_detected} ->
			ok
	end,
	ok.
%
