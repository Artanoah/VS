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

	public ObjectBrokerDispatcher(ServerSocket serverSocket, ObjectBroker objectBroker, boolean debug) {
		this.serverSocket = serverSocket;
		this.objectBroker = objectBroker;
		this.debug = debug;
	}
	
	public void run() {
		while(run) {
			try {
				Socket socket = serverSocket.accept();
				ProcessCallThread pct = new ProcessCallThread(socket, this);
				pct.start();
			} catch(SocketException e) {
				// TODO (kein Stacktrace printen)
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public Object getObject(String objectName) {
		return objectBroker.getObject(objectName);
	}
	
	public void shutdown() {
		this.run = false;
		
		try {
			serverSocket.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
