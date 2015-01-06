-module(station).
-export([start/5, start/4]).

start(InterfaceName, IP, Port, StationType) ->
	start(InterfaceName, IP, Port, StationType, 0).

start(InterfaceName, IP, Port, StationType, Offset) ->
	TimeMaster 	= spawn(time_master, start, [Offset]),
	DataSink 	= spawn(data_sink, start, ["data_sink.log"]),
	DataSource 	= spawn(dummy_data_source, start, []),
	SlotManager = spawn(slot_manager, start, [TimeMaster]),
	Sender 		= spawn(sender, start, [DataSource, SlotManager, TimeMaster, InterfaceName, IP, Port, StationType]),
	Receiver 	= spawn(receiver, start, [DataSink, SlotManager, TimeMaster, InterfaceName, IP, Port]),

	SlotManager ! {missing_references, Sender, Receiver}.