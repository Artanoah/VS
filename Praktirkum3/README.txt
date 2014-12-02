##################################################
#            Erlang Server Readme                #
# Steffen Giersch, Maria Janna Martina Luedemann #
#         Praktikumsgruppe 3, Team 2             #
##################################################

Inhalt des Ordners:

Implementation                   -> Enthält den Filialentest
Implementation_BankAccess        -> Enthält den Banktest
Implementation_CashAccess        -> Enthält den Geldautomattest
NameService                      -> Enthält den Nameservice
03 Entwurf_Giersch_Luedemann.pdf -> Fertiggestellter Entwurf
VSP_Aufgabe3.pdf                 -> Die von ihnen gestellte Aufgabe
README.txt                       -> Diese Datei

	Wie die Tests durchgeführt werden können:

	
Nameservice:
	
Im Ordner /Nameservice ist der Quellcode des NameService.
Dieser muss als erstes gestartet werden. Die Startklasse 
hat den Namen "RunNameService" und kann als Argument einen
Port mitgegeben bekommen. Wenn kein Port mitgegeben wird, 
dann wird der Port auf 50001 eingestellt.


Banktest:

Nachdem der Nameservice gestartet wurde kann der Banktest
gestartet werden. Dieser befindet sich im Ordner 
/Implementation_BankAccess. In /Implementation_BankAccess/bin 
sind die von ihnen veroeffentlichten Tests zu finden, die 
sich wie in ihrer Readme beschrieben ausführen lassen.


Filialentest:

Nachdem die Banktest gestartet wurde kann der Filialentest
durchgeführt werden. Dieser befindet sich im Ordner 
/Implementation. In /Implementation/bin sind die von ihnen
veroeffentlichten Tests zu finden, die sich wie in ihrer 
Readme beschrieben ausführen lassen.


Geldautomattest:

Nachdem der Filialentest gestartet wurde kann der 
Geldautomattest durchgeführt werden. Dieser befindet sich im
Ordner /Implementation_CashAccess. In 
/Implementation_CashAccess/bin sind die von ihnen veroeffentlichten
Tests zu finden, die sich wie in ihrer Readme beschrieben
ausführen lassen.