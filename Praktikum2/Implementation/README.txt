##################################################
#            Erlang Server Readme                #
# Steffen Giersch, Maria Janna Martina Luedemann #
#         Praktikumsgruppe 3, Team 2             #
##################################################


	Wie der Koordinator und die ggtT-Prozesse gestartet werden:

1. Kompiliere alle *.erl Dateien.
2. Starte eine Erlang-Node mit dem Befehl
	(w)erl -name koordinator -setcookie vsp
eine mit dem Befehl
	(w)erl -name starter -setcookie vsp
eine mit dem Befehl
	(w)erl -name <NameserviceNode> -setcookie vsp
eine mit dem Befehl
	(w)erl -name zookeeper -setcookie vsp
Wobei <NameserviceNode> die Selbe wie die nameservicenode aus der client.cfg sein muss 

3. Fuehre in der NameserviceNode den folgenden Befehl aus
	nameservice:start().

4. Fuehre in der KoordinatorNode den folgenden Befehl aus
	koordinator:start().

5. Fuehre in der StarterNode den folgenden Befehl aus
	starter:start(1).

6. In der ZookeeperNode kann nun der Koordinator mit den folgenden Funktionen gesteuert werden:
	kill().
	reset().
	step().
	toggle().
	nudge().
	prompt().
	calc(WggT). -> WggT = WunschGGT
	
	Logs:
Die Logs werden in dem Ordner erstellt, in dem die jeweilige Erlang-Node gestartet wurde.