package mware_lib;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;

public class ObjectBrokerDispatcher extends Thread {
	
	private ServerSocket serverSocket;
	private ObjectBroker objectBroker;
	private boolean debug;
	private boolean run = true;
	private Log log = new Log("ObjectBrokerDispatcher");

	public ObjectBrokerDispatcher(ServerSocket serverSocket, ObjectBroker objectBroker, boolean debug) {
		this.serverSocket = serverSocket;
		this.objectBroker = objectBroker;
		this.debug = debug;
		
		if(debug) {
			log.newInfo("ObjectBrokerDispatcher wird initialisiert");
		}
	}
	
	public void run() {
		if(debug) {
			log.newInfo("run aufgerufen");
		}
		
		while(run) {
			try {
				Socket socket = serverSocket.accept();
				if(debug) {
					log.newInfo("Verbindung angenommen, starte ProcessCallThread");
				}
				ProcessCallThread pct = new ProcessCallThread(socket, this, debug);
				pct.start();
				
				if(debug) {
					log.newInfo("ProcessCallThread erfolgreich gestartet");
				}
			} catch(SocketException e) {
				log.newWarning("SocketException geworfen. Wenn shutdown kurz zuvoraufgerufen wurde ist dies unproblematisch.");
			} catch (IOException e) {
				log.newWarning("IOException geworfen. Vermutlich ist das Accept fehlgeschlagen");
				e.printStackTrace();
			}
		}
	}
	
	public Object getObject(String objectName) {
		return objectBroker.getObject(objectName);
	}
	
	public void shutdown() {
		if(debug) {
			log.newInfo("shutdown aufgerufen");
		}
		this.run = false;
		
		try {
			serverSocket.close();
		} catch (IOException e) {
			log.newWarning("IOException geworfen. serverSocket konnte nicht geschlossen werden.");
			e.printStackTrace();
		}
	}
}
