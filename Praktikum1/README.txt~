##################################################
#            Erlang Server Readme                #
# Steffen Giersch, Maria Janna Martina Luedemann #
#         Praktikumsgruppe 3, Team 2             #
##################################################

	server.cfg:
latency				-> Zeit in Sekunden die der Server verbringen darf ohne irgenteine Nachricht von einem Client bekommen zu haben.
clientlifetime		-> Zeit in Sekunden die ein Client verstreichen lassen darf ohne eine Nachricht an den Server zu schreiben, bis er geloescht wird.
servername			-> Atom welches den Namen des Servers in dieser und in allen Anderen Nodes beschreibt. Dieses Atom muss den selben Wert wie der Servername in der client.cfg haben.
dlqlimit			-> Maximale Anzahl an Nachrichten die in der Deliveryqueue des Servers lagern duerfen. 

	client.cfg:
clients				-> Anzahl der Clients die erzeugt werden
lifetime			-> Zeit in Sekunden die ein Client aktiv bleibt. Wenn dieser Zeitraum ablaeuft wird der Client, egal was er gerade macht, sofort beendet.
servername			-> Atom welches den Namen des Servers in dieser und in allen Anderen Nodes beschreibt. Dieses Atom muss den selben Wert wie der Servername in der server.cfg haben.
sendeintervall		-> Startintervall in Sekunden den der Client wartet, zwischen dem verschicken einer Nachricht und dem verschicken der naechsten Nachricht
praktikumsgruppe	-> Praktikumsgruppennummer
rechnername, 		-> Name des Rechners als Atom auf dem die Node des Servers laeuft. (Bsp.: 'SALLY.informatik.haw-hamburg.de')
nodename, 			-> Name der Node auf der der Server laeuft. (Bsp.: 'googleUltron')
teamnummer			-> Praktikumsteamnummer


	Wie der Server und die Clients gestartet werden:

1. Kompiliere alle *.erl Dateien.
2. Starte eine Erlang-Node mit dem Befehl
	(w)erl -name <ServerNodeName> -setcookie serverCookie
Und eine mit dem Befehl
	(w)erl -name <ClientNodeName> -setcookie serverCookie
Wobei <ServerNodeName> der Selbe wie der nodename aus der client.cfg sein muss und <ClientNodeName> ein beliebiger Name fuer die ClientNode ist.
3. Fuehre in der ServerNode den folgenden Befehl aus
	server:serverStart().
4. Fuehre in der ClientNode (innerhalb von <latency> Sekunden nach dem Starten des Servers) den folgenden Befehl aus
	clientCreator:start().
	
	Logs:
Die Logs werden in dem Ordner erstellt, in dem die jeweilige Erlang-Node gestartet wurde.