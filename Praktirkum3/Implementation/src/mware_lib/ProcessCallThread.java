package mware_lib;

import static mware_lib.Constants.COMMAND_CALL;
import static mware_lib.Constants.MATCHER_DOUBLE;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.Socket;
import java.util.List;

public class ProcessCallThread extends Thread {
	
	private SocketConnection socketConnection;
	private ObjectBrokerDispatcher obd;
	private boolean debug;
	private Log log = new Log("ProcessCallThread");

	public ProcessCallThread(Socket socket, ObjectBrokerDispatcher obd, boolean debug) {
		if(debug) {
			log.newInfo("ProcessCallThread wird initialisiert.");
		}
		
		this.socketConnection = new SocketConnection();
		this.socketConnection.setSocket(socket);
		this.obd = obd;
		this.debug = debug;
	}
	
	public void run() {
		if(debug) {
			log.newInfo("run aufgerufen");
		}
		try {
			Message rawMessage = socketConnection.readMessage();
			
			switch(rawMessage.getCommand()) {
				case COMMAND_CALL:
					if(debug) {
						log.newInfo("COMMAND_CALL Nachricht angekommen");
					}
					
					//Caste die allgemeine Message zu einer MessageCall
					MessageCall messageCall = (MessageCall) rawMessage;
					
					//Hole das Objekt aus der Objektliste fuer das die Methode aufgerufen werden soll
					Object object = obd.getObject(messageCall.getObjectName());
					
					if(debug) {
						if(object != null) {
							log.newInfo("Object wurde erfolgreich vom ObjectBrokerDispatcher geholt");
						} else {
							log.newWarning("Object konnte nicht erfolgreich vom ObjectBrokerDispatcher geholt werden. Arbeite mit null weiter");
						}
					}

					//Erstelle ein Method-Objekt fuer die Methode die aufgerufen werden soll
					String methodName = messageCall.getMethodName();
					Class<? extends Object> objectClass = object.getClass();
					
					//Stelle die Anzahl der benoetigten Argumente fuer den Methodenaufruf fest
					int numberOfArguments = messageCall.getNumberOfArguments();
					
					//Erstelle ein neues Object[] fuer die zu uebergebenden Argumente
					Object[] objectArguments = new Object[numberOfArguments];
					Class<? extends Object>[] methodArgumentClasses = new Class[numberOfArguments];
					
					//Hole die zu uebergebenden Argumente aus der Nachricht
					List<String> stringArguments = messageCall.getArguments();
					
					for(int i = 0; i < numberOfArguments; i++) {
						//Wenn das Argument null ist, dann muss es vorher ein String gewesen sein
						if(stringArguments.get(i) == null) {
							if(debug) {
								log.newInfo("Null wurde als Argument fuer die Methode " + methodName + " uebergeben");
							}
							objectArguments[i] = (Object) stringArguments.get(i);
							methodArgumentClasses[i] = String.class;
						}
						//Wenn das Argument eine Zahl ist, dann wandel es zu einer Zahl um und caste es auf Object
						if(stringArguments.get(i).matches(MATCHER_DOUBLE)) {
							objectArguments[i] = (Object) Double.parseDouble(stringArguments.get(i));
							methodArgumentClasses[i] = double.class;
						} else {
						//Wenn das Arument keine Zahl, also ein String ist, dann caste es nur zu einem Object
							objectArguments[i] = (Object) stringArguments.get(i);
							methodArgumentClasses[i] = String.class;
						}
					}
					
					Method method = objectClass.getMethod(methodName, methodArgumentClasses);
					
					if(debug) {
						log.newInfo("Methode konnte erfolgreicht aus dem Object geholt werden");
					}
					
					try {
						//Rufe die Methode auf das Objekt mit den ermittelten Argumenten auf
						Object objectAnswer = method.invoke(object, objectArguments);
						String answer = null;
						
						if(debug) {
							log.newInfo("Invoke wurde ohne Exception aufgerufen. Schreibe Antwort als String zum Client zurueck.");
						}
						
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
						if(debug) {
							log.newInfo("Die per invoke aufgerufene Methode hat eine Exception geworfen");
						}
						
						Exception exception = (Exception) e.getTargetException();
						socketConnection.writeMessage(new MessageCallErrorAnswer(exception));
					}
					
					if(debug) {
						log.newInfo("Die CallAnfrage wurde erfolgreich bearbeitet");
					}
					break;
				default:
					log.newWarning("Unbekannte Nachricht empfangen. Diese Nachricht wird verworfen");
			}
		} catch (ClassNotFoundException e) {
			log.newWarning("ClassNotFoundException geworfen. Nachricht konnte nicht erfolgreich gelesen werden");
			e.printStackTrace();
		} catch (IOException e) {
			log.newWarning("IOException geworfen. Nachricht konnte entweder nicht gelesen oder geschrieben werden");
		} catch (NoSuchMethodException e) {
			log.newWarning("NoSuchMethodException geworfen. Angefragte Methode konnte nicht gefunden werden");
			e.printStackTrace();
		} catch (SecurityException e) {
			log.newWarning("SecurityException geworfen. Invoke konnte nicht erfolgreich aufgerufen werden.");
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			log.newWarning("IllegalAccessException geworfen. Invoke konnte nicht erfolgreich aufgerufen werden.");
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			log.newWarning("IllegalArgumentException geworfen. Invoke konnte nicht erfolgreich aufgerufen werden");
			e.printStackTrace();
		} finally {
			try {
				socketConnection.closeConnection();
			} catch (IOException e) {
				log.newWarning("IOException geworfen. SocketConnection konnte nicht erfolgreich geschlossen werden.");
				e.printStackTrace();
			}
		}
	}
}
