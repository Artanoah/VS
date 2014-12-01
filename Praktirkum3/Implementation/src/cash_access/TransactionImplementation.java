package cash_access;

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
import mware_lib.Stub;

public class TransactionImplementation extends TransactionImplBase implements Stub {
	
	String objectName;
	String hostName;
	int port;

	public TransactionImplementation(ObjectReference rawObjectRef) {
		this.objectName = rawObjectRef.getName();
		this.hostName = rawObjectRef.getServiceHost();
		this.port = rawObjectRef.getPort();
	}

	@Override
	public void deposit(String accountID, double amount)
			throws InvalidParamException {
		SocketConnection sc = null;
		
		try {
			
			ArrayList<String> arguments = new ArrayList<String>();
			arguments.add(accountID);
			arguments.add(Double.toString(amount));

			sc = new SocketConnection(hostName, port);
			sc.writeMessage(new MessageCall(objectName, "deposit", arguments));
			
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
					messageCallSuccessAnswer.getAnswer();
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
	}

	@Override
	public void withdraw(String accountID, double amount)
			throws InvalidParamException, OverdraftException {
		SocketConnection sc = null;
		
		try {
			ArrayList<String> arguments = new ArrayList<String>();
			arguments.add(accountID);
			arguments.add(Double.toString(amount));
			
			sc = new SocketConnection(hostName, port);
			sc.writeMessage(new MessageCall(objectName, "withdraw", arguments));
			
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
					messageCallSuccessAnswer.getAnswer();
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
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
	}

	@Override
	public double getBalance(String accountID) throws InvalidParamException {
		SocketConnection sc = null;
		
		try {
			ArrayList<String> arguments = new ArrayList<String>();
			arguments.add(accountID);
			
			sc = new SocketConnection(hostName, port);
			sc.writeMessage(new MessageCall(objectName, "getBalance", arguments));
			
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
					return Double.parseDouble(messageCallSuccessAnswer.getAnswer());
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
		
		return 0;
	}
}
