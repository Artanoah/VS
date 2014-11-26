package to_be_distributed;

import static to_be_distributed.Constants.COMMAND_CALLSUCCESSANSWER;
import static to_be_distributed.Constants.COMMAND_CALLSUCCESSANSWER_ANSWER;
import static to_be_distributed.Constants.COMMAND_CALLSUCCESSANSWER_OBJECTNAME;

public class MessageCallSucessAnswer extends Message {

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
