package name_service;

import java.io.IOException;
import java.net.Socket;

import mware_lib.Log;
import mware_lib.Message;
import mware_lib.MessageRebind;
import mware_lib.MessageResolve;
import mware_lib.MessageResolveAnswer;
import mware_lib.ObjectReference;
import mware_lib.SocketConnection;
import static mware_lib.Constants.*;

public class NameServiceThread extends Thread {
	
	private SocketConnection socketConnection;
	private static volatile Log log = new Log("NameServiceThread");
	
	public NameServiceThread(Socket socket) {
		this.socketConnection = new SocketConnection();
		this.socketConnection.setSocket(socket);
	}
	
	public void run() {
		Message rawMessage = null;
		
		try {
			rawMessage = socketConnection.readMessage();
		} catch (ClassNotFoundException | IOException e) {
			e.printStackTrace();
			log.newWarning("Lesen der Message von der SocketConnection fehlgeschlagen");
			return;
		} 
		
		switch(rawMessage.getCommand()) {
			case COMMAND_REBIND:
				MessageRebind messageRebind = (MessageRebind) rawMessage;
				RunNameService.put(messageRebind.getObjectReference().getName(), messageRebind.getObjectReference());
				
				log.newInfo("Neues Objekt wird angemeldet: "+ messageRebind.getObjectReference().getName());
			
				break;
			case COMMAND_RESOLVE:
				MessageResolve messageResolve = (MessageResolve) rawMessage;
				ObjectReference or = RunNameService.get(messageResolve.getObjectName());
				log.newInfo("Aufloesen des Namens " + messageResolve.getObjectName() + " erfolgt");
				
				try {
					socketConnection.writeMessage(new MessageResolveAnswer(or));
				} catch (IOException e) {
					e.printStackTrace();
					log.newWarning("Aufloesen des Namens " + messageResolve.getObjectName() + " fehlgeschlagen");
					return;
				}
				log.newInfo("Neues Objekt wurde erfolgreich aufgeloest: "+ RunNameService.get(messageResolve.getObjectName()));
				break;
			default:
				log.newInfo("Unbekanntes Kommando empfangen: "+ rawMessage.getCommand());
		} 
		
		if(socketConnection != null) {
			try {
				socketConnection.closeConnection();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
}
