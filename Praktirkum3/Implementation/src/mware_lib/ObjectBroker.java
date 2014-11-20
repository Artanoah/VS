package mware_lib;

public class ObjectBroker {
	
	private ObjectBroker(String serviceHost, int listenPort, boolean debug) {
		//TODO
	}
	
	/**
	 * Liefert Einstiegselement in die Middleware aus Anwendersicht sein. 
	 * Das hier erstellte Objekt bietet die Moeglichkeit ein <code>NameService</code>
	 * Objekt zu erzeugen oder die Verbindung zur Middleware zu unterbrechen.
	 * 
	 * @param serviceHost <code>String</code> Host-Name des Namensdienstes
	 * @param listenPort <code>int</code> Port des Namensdienstes
	 * @param debug <code>boolean</code> Schaltet debugging Ausgaben ein oder aus
	 * @return <code>ObjectBroker</code> Erstellter Object-Broker 
	 */
	public static ObjectBroker init(String serviceHost, int listenPort, boolean debug) {
		return new ObjectBroker(serviceHost, listenPort, debug);
	}
	
	/**
	 * Erzeugt ein Stellvertreter-Objekt des Namensdienstes <code>NameService</code>.
	 * Mit diesem Objekt kann der Anwender entweder Objekte anfordern oder beim
	 * Namensdienst registrieren lassen.
	 * 
	 * @return <NameService> Erzeugtes Nameservice-Stellvertreter-Objekt.
	 */
	public NameService getNameService() {
		//TODO
	}
	
	/**
	 * Beendet die Middleware in dieser Anwendung. Alle laufenden Verbindungen und Threads
	 * die zu diesem Prozess gehoeren werden beendet und alle geoeffnetten Sockets werden
	 * geschlossen.
	 */
	public void shutDown() {
		//TODO
	}
}
