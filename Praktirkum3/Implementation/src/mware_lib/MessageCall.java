package mware_lib;

import static mware_lib.Constants.COMMAND_CALL;
import static mware_lib.Constants.COMMAND_CALL_ARGUMENTS;
import static mware_lib.Constants.COMMAND_CALL_METHODNAME;
import static mware_lib.Constants.COMMAND_CALL_OBJECTNAME;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class MessageCall extends Message {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public MessageCall(String objectName, String methodName, ArrayList<String> arguments) {
		super(COMMAND_CALL);
		stringAttributes = new HashMap<String, String>();
		stringListAttributes = new HashMap<String, ArrayList<String>>();
		
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
	
	public List<String> getArguments() {
		return stringListAttributes.get(COMMAND_CALL_ARGUMENTS);
	}
	
	public int getNumberOfArguments() {
		 return getArguments().size();
	}
}
