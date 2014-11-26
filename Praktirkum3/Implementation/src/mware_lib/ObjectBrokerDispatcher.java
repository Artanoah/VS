package mware_lib;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class ObjectBrokerDispatcher extends Thread {
	
	private ServerSocket serverSocket;
	private ObjectBroker objectBroker;
	private boolean run = true;

	public ObjectBrokerDispatcher(ServerSocket serverSocket, ObjectBroker objectBroker) {
		this.serverSocket = serverSocket;
		this.objectBroker = objectBroker;
	}
	
	public void run() {
		while(run) {
			try {
				Socket socket = serverSocket.accept();
				ProcessCallThread pct = new ProcessCallThread(socket, this);
				pct.start();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public Object getObject(String objectName) {
		return objectBroker.getObject(objectName);
	}
}
