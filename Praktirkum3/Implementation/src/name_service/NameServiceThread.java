package name_service;

import java.io.IOException;
import java.net.Socket;

import to_be_distributed.Log;
import to_be_distributed.Message;
import to_be_distributed.MessageRebind;
import to_be_distributed.MessageResolve;
import to_be_distributed.MessageResolveAnswer;
import to_be_distributed.ObjectReference;
import to_be_distributed.SocketConnection;
import static to_be_distributed.Constants.*;

public class NameServiceThread extends Thread {
	
	private SocketConnection socketConnection;
	private Log log = new Log("NameServiceThread");
	
	public NameServiceThread(Socket socket) {
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
				
				log.newInfo("Neues Objekt wird angeldet: "+ messageRebind.getObjectReference().getName());
			
				break;
			case COMMAND_RESOLVE:
				MessageResolve messageResolve = (MessageResolve) rawMessage;
				ObjectReference or = RunNameService.get(messageResolve.getObjectName());
				
				try {
					socketConnection.writeMessage(new MessageResolveAnswer(or));
				} catch (IOException e) {
					e.printStackTrace();
					log.newWarning("Auflösen des Namens " + RunNameService.get(messageResolve.getObjectName())+ " fehlgeschlagen");
					return;
				}
				log.newInfo("Neues Objekt wird aufgelöst: "+ RunNameService.get(messageResolve.getObjectName()));
				break;
			default:
				
		}
	}
}
