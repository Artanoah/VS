package bank_access;

import static mware_lib.Constants.COMMAND_CALLERRORANSWER_INVALIDPARAM;
import static mware_lib.Constants.COMMAND_CALLERRORANSWER_OVERDRAFT;
import static mware_lib.Constants.COMMAND_CALLSUCCESSANSWER;

import java.io.IOException;
import java.util.ArrayList;

import mware_lib.Message;
import mware_lib.MessageCall;
import mware_lib.MessageCallErrorAnswerInvalidParam;
import mware_lib.MessageCallErrorAnswerOverdraft;
import mware_lib.MessageCallSucessAnswer;
import mware_lib.ObjectReference;
import mware_lib.SocketConnection;

public class AccountImplementation extends AccountImplBase {
	
	String objectName;
	String hostName;
	int port;

	public AccountImplementation(ObjectReference rawObjectRef) {
		this.objectName = rawObjectRef.getName();
		this.hostName = rawObjectRef.getServiceHost();
		this.port = rawObjectRef.getPort();
	}

	@Override
	public void transfer(double amount) throws OverdraftException {
		SocketConnection sc = null;
		
		try {
			ArrayList<String> arguments = new ArrayList<String>();
			arguments.add(Double.toString(amount));
			
			sc = new SocketConnection(hostName, port);
			sc.writeMessage(new MessageCall(objectName, "transfer", arguments));
			
			Message rawMessage = sc.readMessage();
			
			switch(rawMessage.getCommand()) {
				case COMMAND_CALLERRORANSWER_INVALIDPARAM:
					MessageCallErrorAnswerInvalidParam messageCallErrorAnswerInvalidParam = (MessageCallErrorAnswerInvalidParam) rawMessage;
					throw new InvalidParamException(messageCallErrorAnswerInvalidParam.getException());
					
				case COMMAND_CALLERRORANSWER_OVERDRAFT:
					MessageCallErrorAnswerOverdraft messageCallErrorAnswerOverdraft = (MessageCallErrorAnswerOverdraft) rawMessage;
					throw new OverdraftException(messageCallErrorAnswerOverdraft.getException());
					
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
		} catch (InvalidParamException e) {
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
	public double getBalance() {
		SocketConnection sc = null;
		
		try {
			ArrayList<String> arguments = new ArrayList<String>();
			
			sc = new SocketConnection(hostName, port);
			sc.writeMessage(new MessageCall(objectName, "getBalance", arguments));
			
			Message rawMessage = sc.readMessage();
			
			switch(rawMessage.getCommand()) {
				case COMMAND_CALLERRORANSWER_INVALIDPARAM:
					MessageCallErrorAnswerInvalidParam messageCallErrorAnswerInvalidParam = (MessageCallErrorAnswerInvalidParam) rawMessage;
					throw new InvalidParamException(messageCallErrorAnswerInvalidParam.getException());
					
				case COMMAND_CALLERRORANSWER_OVERDRAFT:
					MessageCallErrorAnswerOverdraft messageCallErrorAnswerOverdraft = (MessageCallErrorAnswerOverdraft) rawMessage;
					throw new OverdraftException(messageCallErrorAnswerOverdraft.getException());
					
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
		} catch (InvalidParamException e) {
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
