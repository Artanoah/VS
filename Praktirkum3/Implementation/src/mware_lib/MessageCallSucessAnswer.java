package mware_lib;

import static mware_lib.Constants.COMMAND_CALLSUCCESSANSWER;
import static mware_lib.Constants.COMMAND_CALLSUCCESSANSWER_ANSWER;
import static mware_lib.Constants.COMMAND_CALLSUCCESSANSWER_OBJECTNAME;

public class MessageCallSucessAnswer extends Message {

	private static final long serialVersionUID = 1L;

	public MessageCallSucessAnswer(String objectName, String answer) {
		super(COMMAND_CALLSUCCESSANSWER);
		
		stringAttributes.put(COMMAND_CALLSUCCESSANSWER_OBJECTNAME, objectName);
		stringAttributes.put(COMMAND_CALLSUCCESSANSWER_ANSWER, answer);
	}
	
	public String getObjectName() {
		return stringAttributes.get(COMMAND_CALLSUCCESSANSWER_OBJECTNAME);
	}
	
	public String getAnswer() {
		return stringAttributes.get(COMMAND_CALLSUCCESSANSWER_ANSWER);
	}
}
