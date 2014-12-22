-module(receiver).
-export([start/6]).

-record(ctx, {
	sync_manager,
	slot_manager,
	data_sink,
	received_message,
	local_received_time,
	message_count = 0
}).

-record(msg, {
	payload,
	station_type,
	slot,
	timestamp
}).

start(DataSink, SlotManager, SyncManager, Interface, MultiIP, Port) ->
	spawn(fun() -> init(
		DataSink, SlotManager, SyncManager, Interface, MultiIP, Port
	) end).

init(DataSink, SlotManager, SyncManager, Interface, MultiIP, Port) ->
	Context = #ctx{
		sync_manager = SyncManager,
		slot_manager = SlotManager,
		data_sink = DataSink
	},
	udp_proc:start(self(), Interface, MultiIP, Port),
	loop(Context).

loop(Context) ->
	receive
		Msg ->
			NewContext = on(Msg, Context)
	end,
	loop(NewContext).

on({message, Payload, StationType, Slot, Timestamp}, Context) ->
	Context#ctx{
		received_message = #msg{
			payload = Payload,
			station_type = StationType,
			slot = Slot,
			timestamp = Timestamp
		},
		message_count = Context#ctx.message_count + 1,
		local_received_time = sync_util:current_time(Context#ctx.sync_manager)
	};

on({slot_passed}, Context) ->
	handle_messages(Context),
	reset(Context);

on(Any, Context) ->
	io:fwrite("Received unknown message ~p~n", [Any]),
	Context.

reset(Context) ->
	Context#ctx{
		received_message = undefined,
		message_count = 0,
		local_received_time = undefined
	}.

handle_messages(Context) when Context#ctx.message_count == 0 ->
	Context#ctx.slot_manager ! {no_messages};
handle_messages(Context) when Context#ctx.message_count == 1 ->
	Payload = Context#ctx.received_message#msg.payload,
	Slot = Context#ctx.received_message#msg.slot,
	StationType = Context#ctx.received_message#msg.station_type,
	StationTime = Context#ctx.received_message#msg.timestamp,
	LocalTime = Context#ctx.local_received_time,

	Context#ctx.slot_manager ! {slot_reservation, Slot},
	Context#ctx.data_sink ! {data, Payload},
	Context#ctx.sync_manager ! {new_message, StationType, StationTime, LocalTime};
handle_messages(Context) when Context#ctx.message_count > 1 ->
	Context#ctx.slot_manager ! {collision_detected}.
