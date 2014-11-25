package to_be_distributed;

import static to_be_distributed.Constants.*;

public class MessageCallAnswer extends Message {

	public MessageCallAnswer(String objectName, String answer) {
		super(COMMAND_CALLANSWER);
		
		attributes.put("objectName", objectName);
		attributes.put("answer", answer);
	}
	
	public String getObjectName() {
		return (String) attributes.get("objectName");
	}
	
	public String getAnswer() {
		return (String) attributes.get("answer");
	}
}
