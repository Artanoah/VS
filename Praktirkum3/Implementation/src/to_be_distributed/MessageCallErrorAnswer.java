package to_be_distributed;

import static to_be_distributed.Constants.*;

public class MessageCallErrorAnswer extends Message {

	public MessageCallErrorAnswer(Exception e) {
		super(COMMAND_CALLERRORANSWER);
		exceptionAttributes.put(COMMAND_CALLERRORANSWER_ANSWER, e);
	}
	
	public Exception getError() {
		return exceptionAttributes.get(COMMAND_CALLERRORANSWER_ANSWER);
	}
}
