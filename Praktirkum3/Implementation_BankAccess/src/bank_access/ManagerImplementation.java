package bank_access;

import static mware_lib.Constants.COMMAND_CALLERRORANSWER;
import static mware_lib.Constants.COMMAND_CALLSUCCESSANSWER;

import java.io.IOException;
import java.util.ArrayList;

import mware_lib.Message;
import mware_lib.MessageCall;
import mware_lib.MessageCallErrorAnswer;
import mware_lib.MessageCallSucessAnswer;
import mware_lib.ObjectReference;
import mware_lib.SocketConnection;

public class ManagerImplementation extends ManagerImplBase {
	
	String objectName;
	String hostName;
	int port;

	public ManagerImplementation(ObjectReference rawObjectRef) {
		this.objectName = rawObjectRef.getName();
		this.hostName = rawObjectRef.getServiceHost();
		this.port = rawObjectRef.getPort();
	}

	@Override
	public String createAccount(String owner, String branch)
			throws InvalidParamException {
		SocketConnection sc = null;
		
		try {
			ArrayList<Object> arguments = new ArrayList<Object>();
			arguments.add(owner);
			arguments.add(branch);
			Class<?>[] datatypes = new Class<?>[2];
			
			datatypes[0] = String.class;
			datatypes[1] = String.class;
			
			sc = new SocketConnection(hostName, port);
			sc.writeMessage(new MessageCall(objectName, "createAccount", arguments, datatypes));
			
			Message rawMessage = sc.readMessage();
			
			switch(rawMessage.getCommand()) {
				case COMMAND_CALLERRORANSWER:
					MessageCallErrorAnswer messageCallErrorAnswer = (MessageCallErrorAnswer) rawMessage;
					
					if(messageCallErrorAnswer.getException() instanceof InvalidParamException) {
						throw (InvalidParamException) messageCallErrorAnswer.getException();
					} else if (messageCallErrorAnswer.getException() instanceof OverdraftException){
						throw (OverdraftException) messageCallErrorAnswer.getException();
					} else if (messageCallErrorAnswer.getException() instanceof NullPointerException){
						throw (NullPointerException) messageCallErrorAnswer.getException();
					}
					
				case COMMAND_CALLSUCCESSANSWER:
					MessageCallSucessAnswer messageCallSuccessAnswer = (MessageCallSucessAnswer) rawMessage;
					return messageCallSuccessAnswer.getAnswer();
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (OverdraftException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			if(sc != null) {
				try {
					sc.closeConnection();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
		
		return "";
	}
}

