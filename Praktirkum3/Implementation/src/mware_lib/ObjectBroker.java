package mware_lib;

import java.io.IOException;
import java.net.ServerSocket;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import to_be_distributed.Log;

public class ObjectBroker {
	
	private String nameServiceHost;
	private int nameServicePort;
	private List<NameService> nameServices;
	
	private Map<String, Object> sharedObjects;
	
	private int listenPort;
	private ServerSocket serverSocket;
	
	private ObjectBrokerDispatcher obd;
	
	private boolean debug;
	private Log log = new Log("ObjectBroker");
	
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
		this.sharedObjects = new HashMap<String, Object>();
		
		try {
			serverSocket = new ServerSocket(0);
		} catch (IOException e) {
			log.newWarning("Erstellen eines ServerSockets fehlgeschlagen.");
			e.printStackTrace();
		}
		
		listenPort = serverSocket.getLocalPort();
		
		obd = new ObjectBrokerDispatcher(serverSocket, this);
		obd.start();
		log.newInfo("ObjectBrokerDispatcher gestartet");
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
		NameService ns = new NameServiceImplementation(nameServiceHost, nameServicePort, listenPort, debug, this);
		nameServices.add(ns);
		return ns;
	}
	
	/**
	 * Beendet die Middleware in dieser Anwendung. Alle laufenden Verbindungen und Threads
	 * die zu diesem Prozess gehoeren werden beendet und alle geoeffnetten Sockets werden
	 * geschlossen.
	 */
	public void shutDown() {
		//TODO
	}
	
	public Object getObject(String objectName) {
		return sharedObjects.get(objectName);
	}
	
	public void addObject(String name, Object object) {
		sharedObjects.put(name, object);
	}
}
