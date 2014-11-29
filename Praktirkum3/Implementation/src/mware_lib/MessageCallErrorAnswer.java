package mware_lib;

import static mware_lib.Constants.COMMAND_CALLERRORANSWER;
import static mware_lib.Constants.COMMAND_CALLERRORANSWER_ANSWER;

import java.util.HashMap;

public class MessageCallErrorAnswer extends Message {

	private static final long serialVersionUID = 1L;

	public MessageCallErrorAnswer(Exception e) {
		super(COMMAND_CALLERRORANSWER);
		exceptionAttributes = new HashMap<String, Exception>();
		exceptionAttributes.put(COMMAND_CALLERRORANSWER_ANSWER, e);
	}
	
	public Exception getException() {
		return exceptionAttributes.get(COMMAND_CALLERRORANSWER_ANSWER);
	}
}
