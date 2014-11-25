package to_be_distributed;

import static to_be_distributed.Constants.*;

public class MessageCall extends Message {

	public MessageCall(String objectName, String methodName) {
		super(COMMAND_CALL);
		attributes.put("objectName", objectName);
		attributes.put("methodName", methodName);
	}

	public String getObjectName() {
		return (String) attributes.get("objectName");
	}
	
	public String getMethodName() {
		return (String) attributes.get("methodName");
	}
}
