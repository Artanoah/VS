package mware_lib;

import static mware_lib.Constants.COMMAND_CALLERRORANSWER_ANSWER;
import static mware_lib.Constants.COMMAND_CALLERRORANSWER_OVERDRAFT;

public class MessageCallErrorAnswerOverdraft extends Message {

	private static final long serialVersionUID = 1L;

	public MessageCallErrorAnswerOverdraft(Exception e) {
		super(COMMAND_CALLERRORANSWER_OVERDRAFT);
		stringAttributes.put(COMMAND_CALLERRORANSWER_ANSWER, e.getMessage());
	}

	public String getException() {
		return stringAttributes.get(COMMAND_CALLERRORANSWER_ANSWER);
	}
}
