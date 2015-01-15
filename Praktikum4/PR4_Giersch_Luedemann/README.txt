##################################################
#             UDP-Stations Readme                #
# Steffen Giersch, Maria Janna Martina Luedemann #
#         Praktikumsgruppe 3, Team 2             #
##################################################


		### WICHTIG ###

Das Start-Script ist auf die Erlang Version OTP_17.1
angepasst. Die beigefuegten *.beam Dateien sind mit 
der OTP Version 17.1 kompiliert.

Zur Benutzung dieser Version sollte
OTP_17.1 im Ordner /usr/local/erlang liegen. 
Andernfalls muss der Pfad in der Datei erl.sh, 
Zeile 2 angepasst werden.


		### Enthaltene Skripte ###

	startStations.sh

Vorgegebenes Skript zum Starten der Stationen.


	kill.sh

Skript zum beenden aller Prozesse die mit den
Stationen zu tun haben koennen. Dieses Skript
ist mit Vorsicht zu geniessen, da sowohl alle
Java als auch alle Erlang Prozesse beendet
werden.


	erl.sh

Hilfsscript welches alle Argumente an den
darin festgelegten Erlang-Starter 
uebergibt.