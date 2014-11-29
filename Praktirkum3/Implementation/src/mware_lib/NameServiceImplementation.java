package mware_lib;

import static mware_lib.Constants.COMMAND_RESOLVEANSWER;

import java.io.IOException;
import java.net.UnknownHostException;

public class NameServiceImplementation extends NameService {
	
	private String nameServicehost;
	private int nameServicePort;
	private String serverHostName;
	private int serverListenPort;
	private boolean debug;
	private ObjectBroker objectBroker;
	private Log log;
	private boolean run;

	/**
	 * Erstellt ein Nameservice Objekt. Mit diesem Objekt koennen Objekte freigegeben oder aufgeloest werden.
	 * 
	 * @param nameServiceHost <code>String</code> Name des NameService Hosts
	 * @param nameServicePort <code>int</code> Port des NameService Hosts
	 * @param serverHostName <code>String</code> Hostname auf dem der eigene
	 * Objectkroker, also diese Middleware, hoert. Wenn ein Objekt per 
	 * <code>rebind</code> freigegeben wird, dann muss dieser Name in der 
	 * <code>MessageRebind</code> benutzt werden. 
	 * @param serverListenPort <code>int</code> Port auf dem der eigene 
	 * Objectbroker, also diese Middleware, hoert. Wenn ein Objekt per 
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
			int nameServicePort, String serverHostName, int serverListenPort, boolean debug,
			ObjectBroker objectBroker) {
		
		this.nameServicehost = nameServiceHost;
		this.nameServicePort = nameServicePort;
		this.serverHostName = serverHostName;
		this.serverListenPort = serverListenPort;
		this.debug = debug;
		this.objectBroker = objectBroker;
		this.log = new Log("NameServiceImplementation");
		this.run = true;
		
		log.newInfo("NameServiceImplementation instanziiert");
	}

	@Override
	public void rebind(Object servant, String name) {
		
		if(!run) {
			return;
		}
		
		log.newInfo("Rebind des Objektes " + servant + " mit dem Namen " + name);
		
		SocketConnection sc = null;
		
		try {
			String className = getClassName(servant);
			sc = new SocketConnection(nameServicehost, nameServicePort);
			sc.writeMessage(new MessageRebind(new ObjectReference(name, className, serverHostName, serverListenPort)));
			objectBroker.addObject(name, servant);
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			if(sc != null) {
				try {
					sc.closeConnection();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
	}

	@Override
	public Object resolve(String name) {
		
		if(!run) {
			return null;
		}
		
		log.newInfo("Resolve eines Objektes mit dem Namen " + name);
		
		SocketConnection sc = null;
		try {
			sc = new SocketConnection(nameServicehost, nameServicePort);
			sc.writeMessage(new MessageResolve(name));
			Message rawMessage = sc.readMessage();
			
			switch(rawMessage.getCommand()) {
				case COMMAND_RESOLVEANSWER:
					MessageResolveAnswer messageResolveAnswer = (MessageResolveAnswer) rawMessage;
					ObjectReference or = messageResolveAnswer.getObjectReference();
					
					return or;
				
				default:
					//TODO
			}
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			try {
				if(sc != null) {
					sc.closeConnection();
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		return null;
	}
	
	private String getClassName(Object object) throws ClassNotFoundException {
		String akku = "";
		
		if(String.class.isAssignableFrom(object.getClass())) {
			akku = "String";
		} else if(Integer.class.isAssignableFrom(object.getClass())) {
			akku = "Integer";
		} else if(Class.forName("bank_access.AccountImplBase").isAssignableFrom(object.getClass())) {
			akku = "AccountImplBase";
		} else if(Class.forName("bank_access.ManagerImplBase").isAssignableFrom(object.getClass())) {
			akku = "ManagerImplBase";
		} else if(Class.forName("cash_access.TransactionImplBase").isAssignableFrom(object.getClass())) {
			akku = "TransactionImplBase";
		} else {
			akku = "Object";
		}
		
		return akku;
	}
	
	public void shutdown() {
		this.run = false;
	}

}
