##################################################
#            Erlang Server Readme                #
# Steffen Giersch, Maria Janna Martina Luedemann #
#         Praktikumsgruppe 3, Team 2             #
##################################################

Inhalt des Ordners:

Implementation                   -> Enth�lt den Filialentest
Implementation_BankAccess        -> Enth�lt den Banktest
Implementation_CashAccess        -> Enth�lt den Geldautomattest
NameService                      -> Enth�lt den Nameservice
03 Entwurf_Giersch_Luedemann.pdf -> Fertiggestellter Entwurf
VSP_Aufgabe3.pdf                 -> Die von ihnen gestellte Aufgabe
README.txt                       -> Diese Datei

	Wie die Tests durchgef�hrt werden k�nnen:

	
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
sich wie in ihrer Readme beschrieben ausf�hren lassen.


Filialentest:

Nachdem die Banktest gestartet wurde kann der Filialentest
durchgef�hrt werden. Dieser befindet sich im Ordner 
/Implementation. In /Implementation/bin sind die von ihnen
veroeffentlichten Tests zu finden, die sich wie in ihrer 
Readme beschrieben ausf�hren lassen.


Geldautomattest:

Nachdem der Filialentest gestartet wurde kann der 
Geldautomattest durchgef�hrt werden. Dieser befindet sich im
Ordner /Implementation_CashAccess. In 
/Implementation_CashAccess/bin sind die von ihnen veroeffentlichten
Tests zu finden, die sich wie in ihrer Readme beschrieben
ausf�hren lassen.