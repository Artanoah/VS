-module(dlq).
-export([createDLQ/0, add/3, getNext/2, getMaxID/1]).


%Erstellt eine DLQ mit initialer Dummy-Nachricht.
%Die Dummy-Nachricht weicht vom vorgegebenen Entwurf ab, ist allerdings in der Aufgabenstellung so gefordert.
createDLQ() ->
	[{{"Dummy Message", 0, 0, 0, 0},0}].


%Gibt die Nummer der groessten Nachricht aus der DLQ zurueck.
getMaxID([]) ->
	0;

getMaxID([{_, NNr} | []]) ->
	NNr;

getMaxID([_ | DLQ]) ->
	getMaxID(DLQ).


%Gibt die naechstgroessere Nachrichtennummer nach NNr, die Nachricht zu NNr und ein Flag zurueck, was angibt ob 
%die letzte Nachricht zurueckgegeben wurde (true, wenn die letzte Nachricht zurueckgegeben wurde, false wenn nicht).
getNext(NNr, [{Msg, NNr} | []]) ->
	{NNr, Msg, true};

getNext(NNr, [{Msg, NNr}, {_, NNr2} | _]) ->
	{NNr2, Msg, false};

getNext(NNr, [_ | DLQ]) ->
	getNext(NNr, DLQ).


%Fuegt die Nachricht (erster Tupeleintrag) an die DLQ an und loescht das erste Element aus der DLQ, wenn diese voll ist.
add({{Text, COut, HBQIn, _, ClientIn}, Nr}, MaxDLQSize, Queue) ->
	case full(Queue, MaxDLQSize) of
		true	-> 	lists:keysort(2, [{{Text, COut, HBQIn, util:timeMilliSecond(), ClientIn}, Nr}] ++ delete_first(Queue));
		false 	->	lists:keysort(2, [{{Text, COut, HBQIn, util:timeMilliSecond(), ClientIn}, Nr}] ++ Queue)
	end.


%Hilfsmethoden
full(Queue, MaxDLQSize) ->
	MaxDLQSize =< length(Queue).

delete_first([]) ->
	[];

delete_first([_ | Queue]) ->
	Queue.