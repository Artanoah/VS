package mware_lib;

import static to_be_distributed.Constants.COMMAND_CALL;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.Socket;
import java.util.List;

import to_be_distributed.Message;
import to_be_distributed.MessageCall;
import to_be_distributed.MessageCallErrorAnswer;
import to_be_distributed.MessageCallSucessAnswer;
import to_be_distributed.SocketConnection;

public class ProcessCallThread extends Thread {
	
	SocketConnection socketConnection;
	ObjectBrokerDispatcher obd;

	public ProcessCallThread(Socket socket, ObjectBrokerDispatcher obd) {
		this.socketConnection = new SocketConnection();
		this.socketConnection.setSocket(socket);
		this.obd = obd;
	}
	
	public void run() {
		try {
			Message rawMessage = socketConnection.readMessage();
			
			switch(rawMessage.getCommand()) {
				case COMMAND_CALL:
					//Caste die allgemeine Message zu einer MessageCall
					MessageCall messageCall = (MessageCall) rawMessage;
					
					//Hole das Objekt aus der Objektliste fuer das die Methode aufgerufen werden soll
					Object object = obd.getObject(messageCall.getObjectName());
					
					//Erstelle ein Method-Objekt fuer die Methode die aufgerufen werden soll
					Method method = object.getClass().getMethod(messageCall.getMethodName());
					
					//Stelle die Anzahl der benoetigten Argumente fuer den Methodenaufruf fest
					int numberOfArguments = messageCall.getNumberOfArguments();
					
					//Erstelle ein neues Object[] fuer die zu uebergebenden Argumente
					Object[] objectArguments = new Object[numberOfArguments];
					
					//Hole die zu uebergebenden Argumente aus der Nachricht
					List<String> stringArguments = messageCall.getArguments();
					
					for(int i = 0; i < numberOfArguments; i++) {
						//Wenn das Argument eine Zahl ist, dann wandel es zu einer Zahl um und caste es auf Object
						if(stringArguments.get(i).matches("[-+]?\\d*")) {
							objectArguments[i] = (Object) Integer.parseInt(stringArguments.get(i));
						} else {
						//Wenn das Arument keine Zahl, also ein String ist, dann caste es nur zu einem Object
							objectArguments[i] = (Object) stringArguments.get(i);
						}
					}
					
					try {
						//Rufe die Methode auf das Objekt mit den ermittelten Argumenten auf
						Object objectAnswer = method.invoke(object, objectArguments);
						String answer = null;
						
						//Wenn das Ergebnis ein String ist, dann caste es auf einen String
						if(objectAnswer instanceof String) {
							answer = (String) objectAnswer;
						} else {
						//Wenn das Ergebnis kein String, also ein int ist, dann caste es auf int und uebersetze es in einen String
							answer = Integer.toString((int) objectAnswer);
						}
						
						//Schreibe die Antwort an den Empfaenger
						socketConnection.writeMessage(new MessageCallSucessAnswer(messageCall.getObjectName(), answer));
					} catch (InvocationTargetException e) {
						//Wenn durch das invoke eine gewollte Exception geworfen wurde, dann uebertrage diese dementsprechend
						socketConnection.writeMessage(new MessageCallErrorAnswer(e));
					}
					
					break;
				default:
					
			}
		} catch (ClassNotFoundException | IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (NoSuchMethodException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
	}
}
