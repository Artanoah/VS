-module(station).
-export([start/5, start/4]).

start(AtomInterfaceName, AtomIP, AtomPort, AtomStationType) ->
	start(AtomInterfaceName, AtomIP, AtomPort, AtomStationType, '0').

start(AtomInterfaceName, AtomIP, AtomPort, AtomStationType, AtomOffset) ->
	InterfaceName = get_ip_by_interface_name(atom_to_list(AtomInterfaceName)),
	{ok, IP} = inet_parse:address(atom_to_list(AtomIP)),
	{Port, _} = string:to_integer(atom_to_list(AtomPort)),
	StationType = atom_to_list(AtomStationType),
	{Offset, _} = string:to_integer(atom_to_list(AtomOffset)),

	TimeMaster 	= spawn(time_master, start, [util:random(Offset)]),
	DataSink 	= spawn(data_sink, start, ["data_sink.log"]),
	DataSource 	= spawn(dummy_data_source, start, []),
	SlotManager 	= spawn(slot_manager, start, [TimeMaster]),
	Sender 		= spawn(sender, start, [DataSource, SlotManager, TimeMaster, InterfaceName, IP, Port, StationType]),
	Receiver 	= spawn(receiver, start, [DataSink, SlotManager, TimeMaster, InterfaceName, IP, Port]),

	SlotManager ! {missing_references, Sender, Receiver}.
	
	
get_ip_by_interface_name(InterfaceName) ->
	{ok, Interfaces} = inet:getifaddrs(),
	Data = proplists:get_value(InterfaceName, Interfaces),
	Addrs = proplists:lookup_all(addr, Data),
	{ok, Addr} = get_ipv4_address(Addrs),
	Addr.

	
get_ipv4_address([{addr, Addr}|Addrs]) ->
	AddrString = inet:ntoa(Addr),
	get_ipv4_address(inet:parse_ipv4_address(AddrString), Addrs).

	
get_ipv4_address({error, einval}, Addrs) ->
	get_ipv4_address(Addrs);
	
get_ipv4_address(Addr, _Addrs) ->
	Addr.
