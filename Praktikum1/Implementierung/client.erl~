-module(client).
-export([startClient/5]).


%Startet einen neuen Client, der abwechselnd Leser und Redakteur ist.
startClient(Lifetime, SendeIntervall, ClientName, ServerName, Rechnername) ->
	%Logging
	LogFileName = util:get_client_log_file(Rechnername),
	util:logging(LogFileName, ClientName ++ " Start: " ++ util:timeMilliSecond() ++ "\n"),

	%Erstelle einen Timer der den Client nach der Vorgegebenen Zeit beendet
	timer:kill_after(1000*Lifetime),
	sending(Lifetime, SendeIntervall, ClientName, ServerName, LogFileName).
	
%Client loop
sending(Lifetime, SendeIntervall, ClientName, ServerName, LogFileName) ->
	%Starte den Redakteur
	MSGIDList = clientEditor:startSend(SendeIntervall, ClientName, ServerName),
	%Starte den Leser
	clientReader:startRead(ServerName, MSGIDList),
	%Berechne neuen Sendeintervall
	NewSendeIntervall = calcTimer(SendeIntervall),
	%Logging
	util:logging(LogFileName, "Neuer Sendeintervall: " ++ integer_to_list(NewSendeIntervall) ++ " Sekunden (" ++ integer_to_list(SendeIntervall) ++ ")\n"),
	sending(Lifetime, NewSendeIntervall, ClientName, ServerName, LogFileName).

%Ermittelt einen neuen Sendeintervall - entweder eine Sekunde mehr oder weniger als SendeIntervall, aber nicht weniger als 2 Sekunden
calcTimer(SendeIntervall) ->
	case random() of
		true ->
			NewIntervall = SendeIntervall - 1;
		false ->
			NewIntervall = SendeIntervall + 1
	end,
	
	case NewIntervall < 2 of
		true ->
			2;
		false ->
			NewIntervall
	end.

%Erstellt zufaellige booleans. Benutzt die Systemzeit in Mikrosekunden als "Random generator".
%Diese Methode wurde gewaehlt, weil random:uniform(2) zwar zufaellige Zahlen erstellte, aber bei jedem Client die selben
random() ->
	{_, _, MS} = os:timestamp(),
	case (MS div 1000) rem 2 of
		0 -> true;
		1 -> false
	end.