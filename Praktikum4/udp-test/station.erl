-module(station).
-export([start/1]).


start(ID) ->
	erlang:send_after(1000, self(), {timer}),
	Sender = spawn(sender, start, [ID]),
	Receiver = spawn(receiver, start, []),
	loop(ID, Sender, Receiver).


loop(ID, Sender, Receiver) ->
	receive
		{timer} ->
			erlang:send_after(1000, self(), {timer},
			Sender ! {start_send},
			Receiver ! {receive_end},
			loop(ID, Sender, Receiver);
		
		{messages, Messages}
			io:format("Received Messages: ~p~n", [Messages]),
			loop(ID, Sender, Receiver)
		
	end.