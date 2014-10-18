-module(dlq).
-export([createDLQ/1, maxSize/1, size/1, add/2, getNext/2, getMaxID/1]).


%Erstellt eine DLQ mit initialer Dummy-Nachricht.
createDLQ(MaxSize) ->
	createDLQHelper(MaxSize, []).

createDLQHelper(MaxSize, Queue) when length(Queue) < MaxSize - 1 ->
	createDLQHelper(MaxSize, Queue ++ [{{0, 0, 0, 0, 0}, -1}]);

createDLQHelper(MaxSize, Queue) when length(Queue) < MaxSize ->
	Queue ++ [{{"Dummy Message", 0, 0, 0, 0}, 0}].


%Ermittelt die aktuelle Laenge der Queue
size(Queue) ->
	sizeHelper(0, maxSize(Queue), Queue).

sizeHelper(Length, MaxLength, [{{Msg, _, _, _, _}, _} | _]) when Msg /= 0 ->
	MaxLength - Length;

sizeHelper(Length, MaxLength, [_ | Queue]) ->
	sizeHelper(Length + 1, MaxLength, Queue).

%Ermittelt die maximale Laenge der Queue
maxSize(Queue) ->
	length(Queue).


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
add(Queue, {{Text, COut, HBQIn, _, ClientIn}, Nr}) ->
	lists:keysort(2, [{{Text, COut, HBQIn, util:timeMilliSecond(), ClientIn}, Nr}] ++ delete_first(Queue)).


%Hilfsmethoden
full(Queue) ->
	dlq:maxSize(Queue) =< dlq:size(Queue).

delete_first([]) ->
	[];

delete_first([_ | Queue]) ->
	Queue.