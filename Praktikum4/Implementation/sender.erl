-module(sender).
-export([start/7]).


start(DataSource, SlotManager, TimeMaster, Interface, IP, Port, StationType) ->
	Socket = util:openSe(Interface, Port),
	loop(DataSource, SlotManager, TimeMaster, Socket, IP, Port, dummy, 0, StationType).

loop(DataSource, SlotManager, TimeMaster, Socket, IP, Port, Timer, ReservedSendIntervall, StationType) ->
	receive 
		{send_timer} ->
			{SendIntervallBegin, SendIntervallEnd} = ReservedSendIntervall,
			{Slot, Data} = get_slot_and_data(SlotManager, DataSource),
			Time = util:time_master_time(TimeMaster),
			
			case (SendIntervallBegin < Time) and (SendIntervallEnd > Time) of
				% Wenn wir innerhalb unseres Sendeintervalls sind
				true -> 
					Paket = create_paket(StationType, Data, Slot, Time),
					ok = gen_udp:send(Socket, IP, Port, Paket);

				% Wenn wir unseren Sendeintervall verpasst haben
				false ->
					SlotManager ! {slot_missed}
			end,

			loop(DataSource, SlotManager, TimeMaster, Socket, IP, Port, Timer, ReservedSendIntervall, StationType);

		{new_timer, TimeToWait, NewReservedSendIntervall} ->	
			loop(DataSource, SlotManager, TimeMaster, Socket, IP, Port, erlang:new_timer(TimeToWait, self(), {send_timer}), NewReservedSendIntervall, StationType)
	end.

get_slot_and_data(SlotManager, DataSource) ->
	SlotManager ! {get_reservable_slot, self()},
	DataSource  ! {get_payload, self()},

	receive 
		{reservable_slot, Slot} ->
			NewSlot = Slot
	end,

	receive 
		{payload, Data} ->
			NewData = Data
	end,

	{NewSlot, NewData}.


create_paket(StationType, Data, Slot, Time) ->
	StationTypeBin = list_to_binary(StationType),
	DataBin = list_to_binary(Data),
	SlotBin = Slot,
	TimestampBin = Time,

	<<StationTypeBin:1/binary,
	  DataBin:24/binary,
	  SlotBin:8/integer,
	  TimestampBin:64/integer-big>>.
