-module(sender).
-export([start/6]).

-define(DELAY_TOLERANCE_MS, 20).

-record(ctx, {
	socket,
	multicast_ip,
	port,
	sync_manager,
	slot_manager,
	station_type,
	timer,
	send_time,
	current_payload
}).

start(SyncManager, SlotManager, Interface, MultiIP, Port, StationType) ->
	spawn(fun() -> init(
		SyncManager, SlotManager, Interface, MultiIP, Port, StationType
	) end).

init(SyncManager, SlotManager, Interface, MultiIP, Port, StationType) ->
	Socket = werkzeug:openSe(Interface, Port),
	Context = #ctx{
		socket = Socket,
		multicast_ip = MultiIP,
		port = Port,
		sync_manager = SyncManager,
		slot_manager = SlotManager,
		station_type = StationType
	},
	loop(Context).

loop(Context) ->
	receive
		{payload, Payload} ->
			NewContext = on(payload, Context, {Payload});
		{new_timer, WaitTime} ->
			NewContext = on(new_timer, Context, {WaitTime});
		{send} ->
			NewContext = on(send, Context, {});
		{reservable_slot, Slot} ->
			NewContext = on(reservable_slot, Context, {Slot})
	end,
	loop(NewContext).

on(payload, Context, {Payload}) ->
	Context#ctx{ current_payload = Payload };

on(new_timer, Context, {WaitTime}) ->
	cancel_timer(Context#ctx.timer),
	Context#ctx{
		timer = create_timer(WaitTime, {send}),
		send_time = sync_util:current_time(Context#ctx.sync_manager) + WaitTime
	};

on(send, Context, {}) ->
	Context#ctx.slot_manager ! {get_reservable_slot},
	Context;

on(reservable_slot, Context, {Slot}) ->
	SendTime = Context#ctx.send_time,
	CurrentTime = sync_util:current_time(Context#ctx.sync_manager),
	send(Context, SendTime, CurrentTime, Slot),
	Context.

% creates a timer with the given wait time but protects
% erlang:send_after from receiving negative values (badarg)
create_timer(WaitTime, Msg) when WaitTime < 0 ->
	create_timer(0, Msg);
create_timer(WaitTime, Msg) ->
	erlang:send_after(WaitTime, self(), Msg).

cancel_timer(undefined) ->
	ok;
cancel_timer(Timer) ->
	erlang:cancel_timer(Timer).

send(Context, SendTime, CurrentTime, Slot)
when CurrentTime < abs(SendTime) + ?DELAY_TOLERANCE_MS ->
	Packet = createPacket(Context, Slot),
	ok = gen_udp:send(Context#ctx.socket, Context#ctx.multicast_ip, Context#ctx.port, Packet);
send(Context, _, _, _) ->
	Context#ctx.slot_manager ! {slot_missed}.

createPacket(Context, _) when Context#ctx.current_payload == undefined ->
	% send transmission slot missed event
	Context#ctx.slot_manager ! {slot_missed};	
	% log missing payload
	% erlang:error(no_payload_given);
createPacket(Context, Slot) ->
	Payload = list_to_binary (Context#ctx.current_payload),
	StationType = list_to_binary (Context#ctx.station_type),
	Timestamp = sync_util:current_time(Context#ctx.sync_manager),
	% ATTENTION: Station type is a list, hence we have to call list_to_binary first!
	<<StationType:1/binary,
	  Payload:24/binary,
	  Slot:8/integer,
	  Timestamp:64/integer-big>>.
