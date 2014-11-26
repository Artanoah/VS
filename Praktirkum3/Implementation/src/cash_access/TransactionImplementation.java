package cash_access;

import java.io.IOException;
import java.util.ArrayList;

import mware_lib.Message;
import mware_lib.MessageCall;
import mware_lib.MessageCallErrorAnswerInvalidParam;
import mware_lib.MessageCallErrorAnswerOverdraft;
import mware_lib.MessageCallSucessAnswer;
import mware_lib.ObjectReference;
import mware_lib.SocketConnection;
import mware_lib.Stub;
import static mware_lib.Constants.*;

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
		try {
			
			ArrayList<String> arguments = new ArrayList<String>();
			arguments.add(accountID);
			arguments.add(Double.toString(amount));
			
			SocketConnection sc = new SocketConnection(hostName, port);
			sc.writeMessage(new MessageCall(objectName, "deposit", arguments));
			
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
		} catch (OverdraftException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	@Override
	public void withdraw(String accountID, double amount)
			throws InvalidParamException, OverdraftException {
		try {
			
			ArrayList<String> arguments = new ArrayList<String>();
			arguments.add(accountID);
			arguments.add(Double.toString(amount));
			
			SocketConnection sc = new SocketConnection(hostName, port);
			sc.writeMessage(new MessageCall(objectName, "withdraw", arguments));
			
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
		}
	}

	@Override
	public double getBalance(String accountID) throws InvalidParamException {
		try {
			
			ArrayList<String> arguments = new ArrayList<String>();
			arguments.add(accountID);
			
			SocketConnection sc = new SocketConnection(hostName, port);
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
		}
		
		return 0;
	}
}
