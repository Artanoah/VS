package mware_lib;

import java.io.IOException;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ObjectBroker {
	
	private String nameServiceHost;
	private int nameServicePort;
	private List<NameServiceImplementation> nameServices;
	
	private Map<String, Object> sharedObjects;
	
	private int listenPort;
	private ServerSocket serverSocket;
	
	private ObjectBrokerDispatcher obd;
	
	private boolean debug;
	private boolean run;
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
		this.nameServices = new ArrayList<NameServiceImplementation>();
		this.sharedObjects = new HashMap<String, Object>();
		this.run = true;
		
		try {
			serverSocket = new ServerSocket(0);
		} catch (IOException e) {
			log.newWarning("Erstellen eines ServerSockets fehlgeschlagen.");
			e.printStackTrace();
		}
		
		this.listenPort = serverSocket.getLocalPort();
		
		obd = new ObjectBrokerDispatcher(serverSocket, this, debug);
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
		
		if(!run) {
			return null;
		}
		
		NameServiceImplementation ns = null;
		
		try {
			//ns = new NameServiceImplementation(nameServiceHost, nameServicePort, InetAddress.getLocalHost().getCanonicalHostName(), listenPort, debug, this);
			ns = new NameServiceImplementation(nameServiceHost, nameServicePort, InetAddress.getByName("localhost").getCanonicalHostName(), listenPort, debug, this);
			nameServices.add(ns);
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return ns;
	}
	
	/**
	 * Beendet die Middleware in dieser Anwendung. Alle laufenden Verbindungen und Threads
	 * die zu diesem Prozess gehoeren werden beendet und alle geoeffnetten Sockets werden
	 * geschlossen.
	 */
	public void shutDown() {
		obd.shutdown();
		this.run = false;
		
		for(NameServiceImplementation n : nameServices) {
			n.shutdown();
		}
	}
	
	public Object getObject(String objectName) {
		return sharedObjects.get(objectName);
	}
	
	public void addObject(String name, Object object) {
		System.out.println(object.getClass());
		sharedObjects.put(name, object);
	}
}
