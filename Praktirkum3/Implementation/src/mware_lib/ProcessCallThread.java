package mware_lib;

import static mware_lib.Constants.COMMAND_CALL;
import static mware_lib.Constants.MATCHER_DOUBLE;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.Socket;
import java.util.List;

import bank_access.InvalidParamException;
import bank_access.OverdraftException;

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

					//Erstelle ein Method-Objekt fuer die Methode die aufgerufen werden soll			########FEHLER FLIEGT##########
					String methodName = messageCall.getMethodName();
					Class<? extends Object> objectClass = object.getClass();
					//Method method = objectClass.getMethod(methodName);
					
					//Stelle die Anzahl der benoetigten Argumente fuer den Methodenaufruf fest
					int numberOfArguments = messageCall.getNumberOfArguments();
					
					//Erstelle ein neues Object[] fuer die zu uebergebenden Argumente
					Object[] objectArguments = new Object[numberOfArguments];
					Class<? extends Object>[] methodArgumentClasses = new Class[numberOfArguments];
					
					//Hole die zu uebergebenden Argumente aus der Nachricht
					List<String> stringArguments = messageCall.getArguments();
					
					for(int i = 0; i < numberOfArguments; i++) {
						//Wenn das Argument eine Zahl ist, dann wandel es zu einer Zahl um und caste es auf Object
						if(stringArguments.get(i).matches(MATCHER_DOUBLE)) {
							objectArguments[i] = (Object) Double.parseDouble(stringArguments.get(i));
							methodArgumentClasses[i] = Double.class;
						} else {
						//Wenn das Arument keine Zahl, also ein String ist, dann caste es nur zu einem Object
							objectArguments[i] = (Object) stringArguments.get(i);
							methodArgumentClasses[i] = String.class;
						}
					}
					
					Method method = objectClass.getMethod(methodName, methodArgumentClasses);
					
					try {
						//Rufe die Methode auf das Objekt mit den ermittelten Argumenten auf
						Object objectAnswer = method.invoke(object, objectArguments);
						String answer = null;
						
						//Wenn das Ergebnis ein String ist, dann caste es auf einen String
						if(objectAnswer instanceof String) {
							answer = (String) objectAnswer;
						} else if(objectAnswer == null) {
							answer = null;
						} else {
						//Wenn das Ergebnis kein String und nicht null, also ein int ist, dann caste es auf int und uebersetze es in einen String
							answer = Double.toString((double) objectAnswer);
						}
						
						//Schreibe die Antwort an den Empfaenger
						socketConnection.writeMessage(new MessageCallSucessAnswer(messageCall.getObjectName(), answer));
					} catch (InvocationTargetException e) {
						//Wenn durch das invoke eine gewollte Exception geworfen wurde, dann uebertrage diese dementsprechend
						Exception exception = (Exception) e.getTargetException();
						if(exception instanceof InvalidParamException) {
							socketConnection.writeMessage(new MessageCallErrorAnswerInvalidParam(exception));
						} else if(exception instanceof OverdraftException) {
							socketConnection.writeMessage(new MessageCallErrorAnswerOverdraft(exception));
						}
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
