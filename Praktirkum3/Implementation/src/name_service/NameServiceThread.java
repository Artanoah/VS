package name_service;

import java.net.Socket;

import to_be_distributed.SocketConnection;

public class NameServiceThread extends Thread {
	
	private SocketConnection socketConnection;
	
	public NameServiceThread(Socket socket) {
		this.socketConnection.setSocket(socket);
	}
	
	public void run() {
		
	}
}
