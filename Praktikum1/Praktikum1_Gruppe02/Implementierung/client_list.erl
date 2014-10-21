-module(client_list).
-export([create_new/0, add/2, exists/2, update/3, set_time/3, get_last_message_id/2, set_last_message_id/3]).

%Erstellt eine neue ClientList
create_new() ->
	[].

%Fuegt einen neuen Client an die Client List an
add(ClientID, Queue) ->
	[{ClientID, 1, util:time_in_ms()}] ++ Queue.

%Prueft ob ein Client in der ClientList existiert
exists(_, []) ->
	false;

exists(ID, [{ID, _LastNumber, _Time} | _Queue]) ->
	true;

exists(ID, [_ | Queue]) ->
	exists(ID, Queue).

%Loescht alle Clients, die ihre "Lebenszeit" ueberschritten haben aus der ClientList
update(_, _, []) ->
	[];

update(CurrentTime, ClientLifetime, [{Nr, _LastNumber, ClientTime} | Queue]) when ClientTime + ClientLifetime * 1000 =< CurrentTime ->
	%Logging-Mist
	LogFileName = util:get_client_log_file(),
	util:logging(LogFileName, "Client " ++ pid_to_list(Nr) ++ " wird vergessen!..................\n"),
	
	update(CurrentTime, ClientLifetime, Queue);

update(CurrentTime, ClientLifetime, [Client | Queue]) ->
	[Client] ++ update(CurrentTime, ClientLifetime, Queue).

%Setzt den Zeitpunkt an dem sich ein Client das letzte Mal gemeldet hat
set_time(_, _, []) ->
	[];

set_time(ClientID, CurrentTime, [{ClientID, LastNumber, _Time} | Queue]) ->
	[{ClientID, LastNumber, CurrentTime} | Queue];

set_time(ClientID, CurrentTime, [Client | Queue]) ->
	[Client | set_time(ClientID, CurrentTime, Queue)].

%Gibt die Nummer der Nachricht zurueck, die der Client als letztes bekommen hat
get_last_message_id(_, []) ->
	false;

get_last_message_id(ClientID, [{ClientID, Nr, _} | _]) ->
	Nr;

get_last_message_id(ClientID, [_ | Queue]) ->
	get_last_message_id(ClientID, Queue).

%Setzt die Nummer der Nachricht, die der Client als letztes bekommen hat
set_last_message_id(_, _, []) -> 
	[];

set_last_message_id(ClientID, NewID, [{ClientID, _, Time} | Queue]) -> 
	[{ClientID, NewID, Time} | Queue];

set_last_message_id(ClientID, NewID, [Head | Queue]) -> 
	[Head | set_last_message_id(ClientID, NewID, Queue)].