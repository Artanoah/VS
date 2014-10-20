-module(nachrichtendienst).
-export([createClientList/0, getMSG/4]).

createClientList() ->
	client_list:create_new().

	
getMSG(DLQ, PID, ClientList, ClientLifetime) ->
	%Schmeisse ausgelaufene Clients aus der ClientList
	UpdatedClientList = client_list:update(util:time_in_ms(), ClientLifetime, ClientList),
	
	%Wenn der anfragende Client noch nicht oder nicht mehr in der ClientList existert fuege ihn hinzu
	case client_list:exists(PID, UpdatedClientList) of
		false -> ClientListWithPID = client_list:add(PID, UpdatedClientList);
		true -> ClientListWithPID = client_list:set_time(PID, util:time_in_ms(), UpdatedClientList)
	end,
	
	%MSGID wird auf die ID der letzten Nachricht die der Client bekommen hat gesetzt
	MSGID = client_list:get_last_message_id(PID, ClientListWithPID),
	
	%Number wird zur naechsten MSGID die der Client geschickt bekommt,
	%Nachricht wird die Nachricht die der Client geschickt bekommen soll und
	%Terminated gibt an ob die letzte Nachricht fuer diesen Client aus der DLQ geholt wurde
	{Number, Nachricht, Terminated} = dlq:getNext(MSGID, DLQ),
	
	%Aktualisiere die letzte NachrichtenNummer die der Client erhalten hat
	FinalClientList = client_list:set_last_message_id(PID, Number, ClientListWithPID),
	
	%Schicke die Nachricht an den Client
	PID ! {reply, Number, Nachricht, Terminated},
	
	%Logging-Mist
	LogFileName = util:get_server_log_file(),
	
	{Msg, COut, HBQIn, DLQIn, _} = Nachricht,
	util:logging(LogFileName, Msg ++ 
	" " ++ 
	integer_to_list(Number) ++ 
	"te_Nachricht. COut: " ++ 
	COut ++ 
	" HBQ In: " ++ 
	HBQIn ++ 
	"DLQ In: " ++ 
	DLQIn ++ 
	" -getmessages von " ++ 
	pid_to_list(PID) ++ 
	"-" ++ 
	boolean_to_list(Terminated) ++ "\n"),
	
	FinalClientList.
	
boolean_to_list(Flag) ->
	case Flag of 
		true -> "true";
		false -> "false"
	end.