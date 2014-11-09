-module(zoo_keeper).
-export([kill/0, reset/0, toggle/0, nudge/0, prompt/0, calc/1, step/0]).


kill() ->
	send_koordinator({kill, self()}).

reset() ->
	send_koordinator({reset, self()}).

step() ->
	send_koordinator({step, self()}).

toggle() ->
	send_koordinator({toggle, self()}).

nudge() ->
	send_koordinator({nudge, self()}).

prompt() ->
	send_koordinator({prompt, self()}).

calc(WggT) ->
	send_koordinator({calc, WggT, self()}).

% Hilfsfunktionen

send_koordinator(Message) ->
	{ok, ConfigListe} = file:consult("koordinator.cfg"),
	{ok, KoordinatorName} = util:get_config_value(koordinatorname, ConfigListe),
	{ok, NameserviceName} = util:get_config_value(nameservicename, ConfigListe),
	{ok, NameserviceNode} = util:get_config_value(nameservicenode, ConfigListe),

	Known = erlang:whereis(zookeeper),
	case Known of
		undefined -> 
			erlang:register(zookeeper, self()),
			util:wait_for_nameservice(NameserviceNode);
		_ -> ok
	end,
	
	Nameservice = global:whereis_name(NameserviceName),
	util:lookup_name(Nameservice, KoordinatorName) ! Message,

	receive 
		ok -> ok;
		Message -> Message
	end.