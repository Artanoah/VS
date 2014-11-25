package to_be_distributed;

import static to_be_distributed.Constants.COMMAND_CALL;
import static to_be_distributed.Constants.COMMAND_CALL_METHODNAME;
import static to_be_distributed.Constants.COMMAND_CALL_OBJECTNAME;

public class MessageCall extends Message {

	public MessageCall(String objectName, String methodName) {
		super(COMMAND_CALL);
		attributes.put(COMMAND_CALL_OBJECTNAME, objectName);
		attributes.put(COMMAND_CALL_METHODNAME, methodName);
	}

	public String getObjectName() {
		return (String) attributes.get(COMMAND_CALL_OBJECTNAME);
	}
	
	public String getMethodName() {
		return (String) attributes.get(COMMAND_CALL_METHODNAME);
	}
}
