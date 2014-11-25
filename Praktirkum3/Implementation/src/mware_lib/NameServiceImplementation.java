package mware_lib;

public class NameServiceImplementation extends NameService {
	
	private String nameServicehost;
	private int nameServicePort;
	private int serverListenPort;
	private boolean debug;
	private ObjectBroker objectBroker;

	/**
	 * Erstellt ein Nameservice Objekt. Mit diesem Objekt koennen Objekte freigegeben oder aufgeloest werden.
	 * 
	 * @param nameServiceHost <code>String</code> Name des NameService Hosts
	 * @param nameServicePort <code>int</code> Port des NameService Hosts
	 * @param serverListenPort <code>int</code> Port auf dem der eigene 
	 * Objektbroker, also diese Middleware hoert. Wenn ein Objekt per 
	 * <code>rebind</code> freigegeben wird, dann muss dieser Port in der 
	 * <code>MessageRebind</code> benutzt werden. 
	 * @param debug <code>boolean</code> Toggelt das Debugverhalten
	 * @param objectBroker <code>ObjectBroker</code> Der ObjectBroker der 
	 * dieses Objekt initialisiert hat. Wenn die Methode <code>rebind</code> 
	 * aufgerufen wird, dann muss das freigegebene Objekt mit der Methode 
	 * <code>objectBroker.addObject(String name, Object object)</code> an 
	 * diesen <code>ObjectBroker</code> uebergeben werden, damit Methoden 
	 * darauf ausgefuehrt werden koennen.
	 */
	public NameServiceImplementation(String nameServiceHost,
			int nameServicePort, int serverListenPort, boolean debug,
			ObjectBroker objectBroker) {
		
		this.nameServicehost = nameServiceHost;
		this.nameServicePort = nameServicePort;
		this.serverListenPort = serverListenPort;
		this.debug = debug;
		this.objectBroker = objectBroker;
	}

	@Override
	public void rebind(Object servant, String name) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public Object resolve(String name) {
		// TODO Auto-generated method stub
		return null;
	}

}
