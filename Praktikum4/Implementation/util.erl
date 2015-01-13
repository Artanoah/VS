-module(util).
-export([get_config_value/2,logging/2,logstop/0,openSe/2,openSeA/2,openRec/3,openRecA/3,
		 pushSL/2,popSL/1,popfiSL/1,findSL/2,findneSL/2,lengthSL/1,minNrSL/1,maxNrSL/1,emptySL/0,notemptySL/1,delete_last/1,shuffle/1,
		 timeMilliSecond/0,reset_timer/3,
		 type_is/1,to_String/1,
		 bestimme_mis/2,
		 head/1, tail/1, last/1, droplast/1, element_before/2, element_after/2, list_with_size/2, index_of/2, replace_index_with/3, average_int/1, 
		 time_in_ms/0, timestamp_to_list/1, list_to_list/1,
		 get_client_log_file/1, get_server_log_file/1, get_client_log_file/0, get_server_log_file/0,
		 bind_name/3, unbind_name/2, lookup_name/2, wait_for_nameservice/1, send_message_to/3, 
		 toggle_boolean/1, message_to_all/3,
		 wait_random_ms/1, random/1,
		 get_time_master_time/1, console_out/1]).
-define(ZERO, integer_to_list(0)).
-define(TTL, 1).

%% -------------------------------------------
% Werkzeug
%% -------------------------------------------
%%
%% -------------------------------------------
%% Sucht aus einer Config-Liste die gewünschten Einträge
% Beispielaufruf: 	{ok, ConfigListe} = file:consult("server.cfg"),
%                  	{ok, Lifetime} = get_config_value(lifetime, ConfigListe),
%
get_config_value(Key, []) ->
	{nok, Key};
get_config_value(Key, [{Key, Value} | _ConfigT]) ->
	{ok, Value};
get_config_value(Key, [{_OKey, _Value} | ConfigT]) ->
	get_config_value(Key, ConfigT).

%% -------------------------------------------
% Schreibt auf den Bildschirm und in eine Datei
% nebenläufig zur Beschleunigung
% Beispielaufruf: logging('FileName.log',"Textinhalt"),
%
logging(Datei,Inhalt) -> Known = erlang:whereis(logklc),
						case Known of
						undefined -> PIDlogklc = spawn(fun() -> logloop(0) end),
								 erlang:register(logklc,PIDlogklc);
								_NotUndef -> ok
						end,
						logklc ! {Datei,Inhalt},
						ok.

logstop( ) -> 	Known = erlang:whereis(logklc),
				case Known of
					undefined -> false;
					_NotUndef -> logklc ! kill, true
				end.
					
logloop(Y) -> 	receive
					{Datei,Inhalt} -> %io:format(Inhalt),
						file:write_file(Datei,Inhalt,[append]),
						logloop(Y+1);
					kill -> true
				end.

%% -------------------------------------------
%%
% Unterbricht den aktuellen Timer
% und erstellt einen neuen und gibt ihn zurück
%%
reset_timer(Timer,Sekunden,Message) ->
	{ok, cancel} = timer:cancel(Timer),
	{ok,TimerNeu} = timer:send_after(Sekunden*1000,Message),
	TimerNeu.
	
%% Zeitstempel: 'MM.DD HH:MM:SS,SSS'
% Beispielaufruf: Text = lists:concat([Clientname," Startzeit: ",timeMilliSecond()]),
%
timeMilliSecond() ->
	{_Year, Month, Day} = date(),
	{Hour, Minute, Second} = time(),
	Tag = lists:concat([klebe(Day,""),".",klebe(Month,"")," ",klebe(Hour,""),":"]),
	{_, _, MicroSecs} = now(),
	Tag ++ concat([Minute,Second],":") ++ "," ++ toMilliSeconds(MicroSecs)++"|".
toMilliSeconds(MicroSecs) ->
	Seconds = MicroSecs / 1000000,
	%% Korrektur, da string:substr( float_to_list(0.234567), 3, 3). 345 ergibt
	if (Seconds < 1) -> CorSeconds = Seconds + 1;
	   (Seconds >= 1) -> CorSeconds = Seconds
	end,
	string:substr( float_to_list(CorSeconds), 3, 3).
concat(List, Between) -> concat(List, Between, "").
concat([], _, Text) -> Text;
concat([First|[]], _, Text) ->
	concat([],"",klebe(First,Text));
concat([First|List], Between, Text) ->
	concat(List, Between, string:concat(klebe(First,Text), Between)).
klebe(First,Text) -> 	
	NumberList = integer_to_list(First),
	string:concat(Text,minTwo(NumberList)).	
minTwo(List) ->
	case {length(List)} of
		{0} -> ?ZERO ++ ?ZERO;
		{1} -> ?ZERO ++ List;
		_ -> List
	end.

%% -------------------------------------------
% Ermittelt den Typ
% Beispielaufruf: type_is(Something),
%
type_is(Something) ->
    if is_atom(Something) -> atom;
	   is_binary(Something) -> binary;
	   is_bitstring(Something) -> bitstring;
	   is_boolean(Something) -> boolean;
	   is_float(Something) -> float;
	   is_function(Something) -> function;
	   is_integer(Something) -> integer;
	   is_list(Something) -> list;
	   is_number(Something) -> number;
	   is_pid(Something) -> pid;
	   is_port(Something) -> port;
	   is_reference(Something) -> reference;
	   is_tuple(Something) -> tuple
	end.
	
% Wandelt in eine Zeichenkette um
% Beispielaufruf: to_String(Something),
%
to_String(Etwas) ->
	lists:flatten(io_lib:format("~p", [Etwas])).	

% Oeffnen von UDP Sockets, zum Senden und Empfangen 
% Schliessen nicht vergessen: timer:apply_after(?LIFETIME, gen_udp, close, [Socket]),

% openSe(IP,Port) -> Socket
% diesen Prozess PidSend (als Nebenläufigenprozess gestartet) bekannt geben mit
%  gen_udp:controlling_process(Socket, PidSend),
% senden  mit gen_udp:send(Socket, Addr, Port, <MESSAGE>)
openSe(Addr, Port) ->
  io:format("~nAddr: ~p~nPort: ~p~n", [Addr, Port]),
  {ok, Socket} = gen_udp:open(Port, [binary, 	{active, false}, {reuseaddr, true}, {ip, Addr}, {multicast_ttl, ?TTL}, inet, 
												{multicast_loop, true}, {multicast_if, Addr}]),
  Socket.

% openRec(IP,Port) -> Socket
% diesen Prozess PidRec (als Nebenläufigenprozess gestartet) bekannt geben mit
%  gen_udp:controlling_process(Socket, PidRec),
% aktives Abholen mit   {ok, {Address, Port, Packet}} = gen_udp:recv(Socket, 0),
openRec(MultiCast, Addr, Port) ->
  io:format("~nMultiCast: ~p~nAddr: ~p~nPort: ~p~n", [MultiCast, Addr, Port]),
  {ok, Socket} = gen_udp:open(Port, [binary, 	{active, false}, {reuseaddr, true}, {multicast_if, Addr}, inet, 
												{multicast_ttl, ?TTL}, {multicast_loop, true}, {add_membership, {MultiCast, Addr}}]),
  Socket.

  % Aktives UDP-Socket:
% openSe(IP,Port) -> Socket
% diesen Prozess PidSend (als Nebenläufigenprozess gestartet) bekannt geben mit
%  gen_udp:controlling_process(Socket, PidSend),
% senden  mit gen_udp:send(Socket, Addr, Port, <MESSAGE>)
openSeA(Addr, Port) ->
  io:format("~nAddr: ~p~nPort: ~p~n", [Addr, Port]),
  {ok, Socket} = gen_udp:open(Port, [binary, 	{active, true}, {ip, Addr}, inet, 
												{multicast_loop, false}, {multicast_if, Addr}]),
  Socket.
 
% openRec(IP,Port) -> Socket
% diesen Prozess PidRec (als Nebenläufigenprozess gestartet) bekannt geben mit
%  gen_udp:controlling_process(Socket, PidRec),
% passives Empfangen mit   receive	{udp, ReceiveSocket, IP, InPortNo, Packet} -> ... end
openRecA(MultiCast, Addr, Port) ->
  io:format("~nMultiCast: ~p~nAddr: ~p~nPort: ~p~n", [MultiCast, Addr, Port]),
  {ok, Socket} = gen_udp:open(Port, [binary, 	{active, true}, {multicast_if, Addr}, inet, 
												{multicast_ttl, ?TTL}, {multicast_loop, false}, {add_membership, {MultiCast, Addr}}]),
  Socket.
  

	
%% -------------------------------------------
%% Mischt eine Liste
% Beispielaufruf: NeueListe = shuffle([a,b,c]),
%
shuffle(List) -> shuffle(List, []).
shuffle([], Acc) -> Acc;
shuffle(List, Acc) ->
    {Leading, [H | T]} = lists:split(random:uniform(length(List)) - 1, List),
    shuffle(Leading ++ T, [H | Acc]).

%% -------------------------------------------
% Sortierte Liste. Kleinstes Element steht links (hinten), groesstes rechts (vorn)
%
%%push2SL fuegt ein Element gemaess Sortierung ein
%
% Wenn ElemNr des Elementes aus der SL groesser oder gleich ist, als die des
% einzufügenden Elementes, füge das Element per Rekursion rechts davon ein
pushSL([{ElemNr, Elem}|TSL], {NElemNr,NElem}) when ElemNr >= NElemNr ->
	[{ElemNr, Elem}|pushSL(TSL,{NElemNr,NElem})];
% Wenn ElemNr des Elementes aus der SL kleiner ist, als die des
% einzufügenden Elementes, füge das Element direkt vor diesem Element(links) davon ein
pushSL([{ElemNr, Elem}|TSL], {NElemNr,NElem}) when ElemNr < NElemNr ->
	[{NElemNr,NElem},{ElemNr, Elem}|TSL];
% Wenn Keine der vorhandenen Nachrichten eine kleinere Elementnummer
% hat, füge das neue Element ans Ende der SL ein
pushSL([], {NElemNr,NElem}) ->
	[{NElemNr,NElem}].

%%popSL loescht Element mit kleinster Nummer, also letztes Element
%
% bei leerer Liste idempotent
popSL([]) -> [];
% letztes Element wird geloescht
popSL([_Entity]) -> [];
% Rekursion bis ans Ende der Liste
popSL([Entity|TSL]) -> [Entity|popSL(TSL)].

%%popfiSL loescht Element mit groesster Nummer, also erstes Element
%
% bei leerer Liste idempotent
popfiSL([]) -> [];
% erstes Element wird geloescht
popfiSL([_Entity|TSL]) -> TSL.

%%findSL sucht ein Element mit bestimmter Nummer
%
% erfolgreicher Fall
findSL([{SNr, Elem}|_TSL],SNr) -> {SNr, Elem};
% rekursive Suche
findSL([{ElemNr, _Elem}|TSL],SNr) when ElemNr > SNr -> findSL(TSL,SNr);
% bei leeren Liste: Fehlercode
findSL([],_SNr) -> {-1,nok};
% Element nicht vorhanden: Fehlercode
findSL([{ElemNr, _Elem}|_TSL],SNr) when ElemNr < SNr -> {-1,nok}.

%%findneSL sucht ein bestimmtes Element gemaess Nummer
% gibt ggf das naechst groessere Element zurueck
%
% erfolgreicher Fall
findneSL([{SNr, Elem}|_TSL],SNr) -> {SNr, Elem};
% Element nicht vorhanden: es wird das naechst groessere Element genommen
findneSL([{ElemNr2, Elem2},{ElemNr1, _Elem1}|_TSL],SNr) when (ElemNr2 > SNr) and (SNr > ElemNr1) -> {ElemNr2, Elem2};
% rekursive Suche
findneSL([{ElemNr, _Elem}|TSL],SNr) when ElemNr > SNr -> findneSL(TSL,SNr);
% Element nicht vorhanden und es gibt kein groesseres Element: Fehlercode
findneSL([{ElemNr, _Elem}|_TSL],SNr) when SNr > ElemNr -> {-1,nok};
% bei leeren Liste: Fehlercode
findneSL([],_SNr) -> {-1,nok}.

%%Laenge der Liste
%
lengthSL(SL) -> length(SL).

%%kleinste Nummer in SL
%
% bei leeren Liste: Fehlercode
minNrSL([]) -> -1;
% erfolgreicher Fall
minNrSL([{ElemNr, _Elem}]) -> ElemNr;
% rekursive Suche
minNrSL([_Entity|TSL]) -> minNrSL(TSL).

%%groesste Nummer in SL
%
% bei leeren Liste: Fehlercode
maxNrSL([]) -> -1;
% erfolgreicher Fall
maxNrSL([{ElemNr, _Elem}|_TSL]) -> ElemNr.

%%leere SL erzeugen
%
emptySL( ) -> [].

%%prueft auf nicht leere Liste
%
notemptySL([]) -> false;
notemptySL(_SL) -> true.
	
%% -------------------------------------------
%% Löscht das letzte Element einer Liste
%
delete_last([]) -> [];
delete_last([_Head]) -> [ ];
delete_last([Head|Tail]) -> [Head|delete_last(Tail)].

% schneller:
% delete_last(List) ->
%   [_|B] = lists:reverse(List),
%   lists:reverse(B).

%% -------------------------------------------
%
% initialisiert die Mi der ggT-Prozesse, um den
% gewünschten ggT zu erhalten.
% Beispielaufruf: bestimme_mis(42,88),
% 42: gewünschter ggT
% 88: Anzahl benötigter Zahlen
% 
%%
bestimme_mis(WggT,GGTsCount) -> bestimme_mis(WggT,GGTsCount,[]).
bestimme_mis(_WggT,0,Mis) -> Mis;
bestimme_mis(WggT,GGTs,Mis) -> 
	Mi = einmi([11, 29, 53, 71, 97, 113, 443, 977],WggT),
	Enthalten = lists:member(Mi,Mis), 
	if 	Enthalten -> bestimme_mis(WggT,GGTs,Mis);
		true ->	bestimme_mis(WggT,GGTs-1,[Mi|Mis])
	end.	
% berechnet ein Mi
einmi([],Akku) -> Akku;	
einmi([Prim|Prims],Akku) ->
	Expo = random:uniform(3)-1, % 0 soll möglich sein!
	AkkuNeu = trunc(Akku * math:pow(Prim,Expo)), % trunc erzeugt integer, was für rem wichtig ist
	einmi(Prims,AkkuNeu).		


%% -------------------------------------------
%Eigene Utility-Methoden
head([]) ->
	[];

head([X | _]) ->
	X.


tail([]) ->
	[];

tail([_ | XS]) ->
	XS.


last([]) ->
	[];

last([X | []]) ->
	X;

last([_ | XS]) ->
	last(XS).


element_before(_, []) ->
	erlang:error("Element konnte nicht gefunden werden\n");

element_before(Element, [Value, Element | _]) ->
	Value;

element_before(Element, [_ | List]) -> 
	element_before(Element, List).


element_after(_, [_ | []]) ->
	erlang:error("Element konnte nicht gefunden werden\n");

element_after(Element, [Element, Value | _]) ->
	Value;

element_after(Element, [_ | List]) ->
	element_after(Element, List).

 
index_of(Item, List) -> 
	index_of(Item, List, 1).

index_of(_, [], _)  -> 
	not_found;

index_of(Item, [Item|_], Index) -> 
	Index;

index_of(Item, [_|Tl], Index) -> 
	index_of(Item, Tl, Index+1).
 

replace_index_with(Index, Element, StatusList) ->
	replace_index_with(1, Index, Element, StatusList).

replace_index_with(Counter, Counter, Element, [_ | StatusList]) ->
	[Element] ++ StatusList;

replace_index_with(Counter, Index, Element, [Head | StatusList]) ->
	[Head] ++ replace_index_with(Counter + 1, Index, Element, StatusList).


list_to_list([]) ->
	"\n";

list_to_list([Head | Tail]) ->
	if 
		is_atom(Head) ->
			atom_to_list(Head) ++ ", " ++ list_to_list(Tail);
		is_number(Head) ->
			integer_to_list(Head) ++ ", " ++ list_to_list(Tail)
	end.
	


list_with_size(0, _) ->
	[];

list_with_size(Size, Element) ->
	[Element] ++ list_with_size(Size - 1, Element).
 
 
average_int([]) ->
	0;

average_int(List) ->
	lists:sum(List) div length(List).


time_in_ms() ->
	time_in_ms_helper(erlang:now()).

time_in_ms_helper({MegS, S, MS}) ->
	((MegS * 1000000 + S) * 1000000 + MS) div 1000.


get_client_log_file(Rechnername) ->
	"client_" ++ util:droplast(util:tail(pid_to_list(self()))) ++ "_" ++ atom_to_list(Rechnername) ++ ".log".

get_client_log_file() ->
	{ok, ConfigListe} = file:consult("client.cfg"),
    {ok, Rechnername} = util:get_config_value(rechnername, ConfigListe),
	"client_" ++ util:droplast(util:tail(pid_to_list(self()))) ++ "_" ++ atom_to_list(Rechnername) ++ ".log".

get_server_log_file(ServerName) ->
	"Server_" ++ util:droplast(util:tail(pid_to_list(self()))) ++ "_" ++ atom_to_list(ServerName) ++ ".log".

get_server_log_file() ->
	{ok, ConfigListe} = file:consult("server.cfg"),
	{ok, ServerName} = util:get_config_value(servername, ConfigListe),
	"Server_" ++ util:droplast(util:tail(pid_to_list(self()))) ++ "_" ++ atom_to_list(ServerName) ++ ".log".


droplast(X) ->
	droplasthelper(X, []).

droplasthelper([_ | []], List) ->
	List;

droplasthelper([X | XS], List) ->
	droplasthelper(XS, List ++ [X]).


timestamp_to_list(Timestamp) ->
	if is_list(Timestamp) -> Timestamp;
	   is_number(Timestamp) -> integer_to_list(Timestamp)
	end.


bind_name(Nameservice, Name, NameserviceNode) ->
	register(Name, self()),
	wait_for_nameservice(NameserviceNode),

	Nameservice ! {self(),{bind, Name, node()}},
	
	receive 
		ok -> ok;
		in_use -> in_use
	end.


unbind_name(Nameservice, Name) ->
	Nameservice ! {self(), {unbind, Name}},
	
	receive
		ok -> ok
	end.


lookup_name(Nameservice, Name) ->
	Nameservice ! {self(), {lookup, Name}},

	timer:sleep(50),

	receive
		not_found -> not_found;
		{pin,ID} -> ID
	end.


send_message_to(Message, Name, Nameservice) ->
	case is_atom(Name) of
		true ->
			PID = lookup_name(Nameservice, Name),
			case PID == not_found of
				true ->
					error;
				false ->
					PID ! Message
			end;
		false ->
			Name ! Message
	end.


wait_for_nameservice(NameserviceNode) ->
	Answer = net_adm:ping(NameserviceNode),
	timer:sleep(500),
	
	if 
		Answer == pang -> 
			wait_for_nameservice(NameserviceNode);
		Answer == pong ->
			ok
	end.


toggle_boolean(Boolean) ->
	case Boolean of
		true -> false;
		false -> true
	end.


message_to_all(_, [], _) ->
	ok;

message_to_all(Message, [Receiver | ReceiverList], Nameservice) ->
	lookup_name(Nameservice, Receiver) ! Message,
	message_to_all(Message, ReceiverList, Nameservice).


wait_random_ms(Max) ->
	{_, _, MS} = os:timestamp(),
	Time = MS rem Max,
	timer:sleep(Time).


get_time_master_time(TimeMaster) ->
	TimeMaster ! {get_current_time, self()},
	receive 
		{current_time, Time} ->
			Time
	end.


console_out(String) ->
	ok.
	%spawn(fun() -> console_out_helper(String) end).

console_out_helper(String) ->
	io:fwrite(String ++"~n").


random(0) ->
	0;

random(Max) ->
	{_, _, MS} = os:timestamp(),
	(MS rem Max) + 1.
	