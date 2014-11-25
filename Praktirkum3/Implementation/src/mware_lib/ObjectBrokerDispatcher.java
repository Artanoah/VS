package mware_lib;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class ObjectBrokerDispatcher extends Thread {
	
	private ServerSocket serverSocket;
	private ObjectBroker objectBroker;

	public ObjectBrokerDispatcher(ServerSocket serverSocket, ObjectBroker objectBroker) {
		this.serverSocket = serverSocket;
		this.objectBroker = objectBroker;
	}
	
	public void run() {
		try {
			Socket socket = serverSocket.accept();
			ProcessCallThread pct = new ProcessCallThread(socket, this);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public Object getObject(String objectName) {
		return objectBroker.getObject(objectName);
	}
}
