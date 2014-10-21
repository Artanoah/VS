-module(hbq).
-export([createHBQ/0, dropmessage/3]).


createHBQ() ->
	[].

%Fuege eine Nachricht zur HBQ hinzu. Wenn die HBQ voll ist, oder die Nachrichten in der HBQ an die in der DLQ anschliessen, dann fuelle die DLQ auf.	
dropmessage(HBQueue, DLQueue, {{Text, COut, _, DLQIn, ClientIn}, Nr}) ->
	{ok, ConfigListe} = file:consult("server.cfg"),
	{ok, ServerName} = util:get_config_value(servername, ConfigListe),
	LogFileName = util:get_server_log_file(ServerName),

	case Nr < dlq:getMaxID(DLQueue) of
		%Wenn die neue Nachricht zu alt ist um noch in die DLQ eingereiht zu werden lasse sie einfach aus und gib die HBQ und DLQ unveraendert zurueck
		true ->
			{HBQueue, DLQueue}
			;
		%Wenn die neue Nachricht noch jetzt oder spaeter in die DLQ eingereiht werden kann
		false ->
			%Fuege die neue Nachricht in die HBQ und sortiere diese nach Nachrichtennummer
			HBQueueFilled = lists:keysort(2, [{{Text, COut, util:timeMilliSecond(), DLQIn, ClientIn}, Nr} | HBQueue]),
			
			%Wenn die HBQ voll ist wird die Luecke zwischen DLQ und HBQ geschlossen und eine entsprechende Fehlernachricht generiert
			case is_hbq_full(HBQueueFilled, dlq:maxSize(DLQueue)) of
				true -> 
					{_, LastMessageNumber} = util:head(HBQueueFilled),
					ErrorText = "***Fehlernachricht fuer Nachrichten " ++ integer_to_list(dlq:getMaxID(DLQueue) + 1) ++ " bis " ++ integer_to_list(LastMessageNumber - 1) ++ " um " ++ util:timeMilliSecond(),
					ErrorMessage = {{ErrorText, "", "", "", ""}, LastMessageNumber - 1},
					DLQueueFilled = dlq:add(DLQueue, ErrorMessage),
					util:logging(LogFileName, ErrorText  ++ "\n");
				false ->
					DLQueueFilled = DLQueue
			end,
					
			%Wenn es keine Luecke zwischen HBQ und DLQ gibt oder die HBQ voll ist, fuelle so lange Elemente von der HBQ in die DLQ, bis entweder eine neue Luecke gefunden wird oder die HBQ leer ist
			case hbqFollowsDlq(HBQueueFilled, DLQueueFilled) or is_hbq_full(HBQueueFilled, dlq:maxSize(DLQueueFilled)) of
				true	-> 
					{_, HeadNum} = util:head(HBQueueFilled),
					{HBQueueDone, DLQueueDone, Log} = fill_until_error(dlq:maxSize(DLQueueFilled), [HeadNum], util:tail(HBQueueFilled), dlq:add(DLQueueFilled, util:head(HBQueueFilled))),
					util:logging(LogFileName, "QVerwaltung>>> Nachrichten " ++ integer_to_list(lists:min(Log)) ++ " bis " ++ integer_to_list(lists:max(Log)) ++ " von HBQ in DLQ transferiert\n");
				false 	-> 
					{HBQueueDone, DLQueueDone} = {HBQueueFilled, DLQueueFilled}
			end,
			%Gib die neue HBQ und die neue DLQ als Tupel zurueck
			{HBQueueDone, DLQueueDone}
	end.
			


%Hilfsmethoden
fill_until_error(_, Log, [], DLQ) ->
	{[], DLQ, Log};

fill_until_error(MaxDLQSize, Log, HBQ, DLQ)  ->
	case hbqFollowsDlq(HBQ, DLQ) of
		true 	-> 
			{_, HeadNum} = util:head(HBQ),
			fill_until_error(MaxDLQSize, [HeadNum] ++ Log, util:tail(HBQ), dlq:add(DLQ, util:head(HBQ)));
		false	-> 
			{HBQ, DLQ, Log}
	end.


hbqFollowsDlq([], _) ->
	false;

hbqFollowsDlq(HBQ, DLQ) ->
	get_num(util:head(HBQ)) - 1 == get_num(util:last(DLQ)).


get_num({_, Nr}) ->
	Nr.


is_hbq_full(Queue, MaxDLQSize) ->
	MaxDLQSize div 2 < length(Queue).