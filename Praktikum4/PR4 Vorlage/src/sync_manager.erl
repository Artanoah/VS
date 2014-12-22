-module(sync_manager).
-export([start/2]).

-define(DEVIATION_THRESHOLD_MS, 1).

-record(ctx, {
	offset = 0,
	deviations = [],
	station_type
}).

start(Offset, StationType) ->
	Context = #ctx{
		offset = Offset,
		station_type = StationType
	},
	spawn(fun() -> loop(Context) end).

loop(Context) ->
	receive
		Msg ->
			NewContext = on(Msg, Context)
	end,
	loop(NewContext).

on({new_message, StationType, StationTime, LocalReceivedTime}, Context) ->
	Deviation = StationTime - LocalReceivedTime,
	add_deviation(Context, StationType, Deviation);

on({get_current_time, PID}, Context) ->
	Time = current_time(Context),
	PID ! {current_time, Time},
	Context;

on({sync}, Context) ->
	sync_time(Context);

on({reset}, Context) ->
	Context#ctx {
	  deviations = []
	};

on(Any, Context) ->
	io:fwrite("Received unknown message ~p~n", [Any]),
	Context.

sync_time(Context) when length(Context#ctx.deviations) == 0 ->
	Context;
sync_time(Context) ->
	Deviation = calculate_deviation(Context),
	Context#ctx{
		offset = Context#ctx.offset + Deviation
	}.

calculate_deviation(Context) ->
	DeviationSum = lists:sum(Context#ctx.deviations),
	round(DeviationSum / deviations_count(Context)).

deviations_count(Context) when Context#ctx.station_type == "A" ->
	length(Context#ctx.deviations) + 1;
deviations_count(Context) ->
	length(Context#ctx.deviations).

add_deviation(Context, ForeignType, Deviation)
when ForeignType == "A", abs(Deviation) > ?DEVIATION_THRESHOLD_MS ->
	Context#ctx{ deviations =  [Deviation|Context#ctx.deviations] };
add_deviation(Context, _, _) ->
	Context.

current_time(Context) ->
	Offset = Context#ctx.offset,
	{MegaSecs, Secs, MicroSecs} = erlang:now(),
	(MegaSecs * 1000000000 + Secs * 1000 + MicroSecs div 1000) + Offset.
