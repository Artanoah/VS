package mware_lib;

import java.io.IOException;
import java.net.ServerSocket;
import java.util.ArrayList;
import java.util.List;

public class ObjectBroker {
	
	private String nameServiceHost;
	private int nameServicePort;
	private List<NameService> nameServices;
	
	private int listenPort;
	private ServerSocket serverSocket;
	
	private ObjectBrokerDispatcher obd;
	
	private boolean debug;
	
	/**
	 * 
	 * 
	 * @param serviceHost <code>String</code>
	 * @param listenPort <code>int</code>
	 * @param debug <code>boolean</code>
	 */
	private ObjectBroker(String serviceHost, int listenPort, boolean debug) {
		this.nameServiceHost = serviceHost;
		this.nameServicePort = listenPort;
		this.debug = debug;
		this.nameServices = new ArrayList<NameService>();
		
		try {
			serverSocket = new ServerSocket(0);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		listenPort = serverSocket.getLocalPort();
		
		obd = new ObjectBrokerDispatcher(serverSocket);
		obd.start();
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
