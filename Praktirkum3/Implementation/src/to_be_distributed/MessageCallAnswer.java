package to_be_distributed;

import static to_be_distributed.Constants.COMMAND_CALLANSWER;
import static to_be_distributed.Constants.COMMAND_CALLANSWER_ANSWER;
import static to_be_distributed.Constants.COMMAND_CALLANSWER_OBJECTNAME;

public class MessageCallAnswer extends Message {

	public MessageCallAnswer(String objectName, String answer) {
		super(COMMAND_CALLANSWER);
		
		attributes.put(COMMAND_CALLANSWER_OBJECTNAME, objectName);
		attributes.put(COMMAND_CALLANSWER_ANSWER, answer);
	}
	
	public String getObjectName() {
		return (String) attributes.get(COMMAND_CALLANSWER_OBJECTNAME);
	}
	
	public String getAnswer() {
		return (String) attributes.get(COMMAND_CALLANSWER_ANSWER);
	}
}
