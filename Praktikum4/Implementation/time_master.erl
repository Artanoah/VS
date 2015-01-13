-module(time_master).
-export([start/1]).


start(Offset) ->
	loop(Offset, []).

loop(Offset, Abweichungen) ->
	receive
		% Anfrage nach aktueller Zeit
		{get_current_time, PID} ->
			PID ! {current_time, util:time_in_ms() + Offset},
			loop(Offset, Abweichungen);
		
		% Eine neue Nachricht von einer 'A'-Station ist eingegangen
		{new_message, FremdstationZeit, EingangsZeit} ->
			Abweichung = FremdstationZeit - EingangsZeit,
			loop(Offset, [Abweichung | Abweichungen]);

		% Ein Synchronisationsbefehl ist eingegangen
		{sync} ->
			%util:console_out("time_master: Synchronisiere"),
			DurchschnittlicheAbweichung = util:average_int(Abweichungen),
			loop(Offset + (DurchschnittlicheAbweichung), [])
	end.