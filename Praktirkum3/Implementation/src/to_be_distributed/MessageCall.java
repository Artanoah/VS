package to_be_distributed;

import static to_be_distributed.Constants.COMMAND_CALL;
import static to_be_distributed.Constants.COMMAND_CALL_ARGUMENTS;
import static to_be_distributed.Constants.COMMAND_CALL_METHODNAME;
import static to_be_distributed.Constants.COMMAND_CALL_OBJECTNAME;

import java.util.ArrayList;
import java.util.List;

public class MessageCall extends Message {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public MessageCall(String objectName, String methodName, ArrayList<String> arguments) {
		super(COMMAND_CALL);
		stringAttributes.put(COMMAND_CALL_OBJECTNAME, objectName);
		stringAttributes.put(COMMAND_CALL_METHODNAME, methodName);
		stringListAttributes.put(COMMAND_CALL_ARGUMENTS, arguments);
	}

	public String getObjectName() {
		return stringAttributes.get(COMMAND_CALL_OBJECTNAME);
	}
	
	public String getMethodName() {
		return stringAttributes.get(COMMAND_CALL_METHODNAME);
	}
	
	@SuppressWarnings("unchecked")
	public List<String> getArguments() {
		return stringListAttributes.get(COMMAND_CALL_ARGUMENTS);
	}
	
	public int getNumberOfArguments() {
		 return getArguments().size();
	}
}
