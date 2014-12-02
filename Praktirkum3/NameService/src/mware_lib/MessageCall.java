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

	public MessageCall(String objectName, String methodName, ArrayList<Object> arguments, Class<?>[] datatypes) {
		super(COMMAND_CALL);
		stringAttributes = new HashMap<String, String>();
		attributes = new ArrayList<Object>();
		this.datatypes = datatypes;
		
		
		stringAttributes.put(COMMAND_CALL_OBJECTNAME, objectName);
		stringAttributes.put(COMMAND_CALL_METHODNAME, methodName);
		
		for(Object o : arguments) {
			attributes.add(o);
		}
	}

	public String getObjectName() {
		return stringAttributes.get(COMMAND_CALL_OBJECTNAME);
	}
	
	public String getMethodName() {
		return stringAttributes.get(COMMAND_CALL_METHODNAME);
	}
	
	public Class<?>[] getDatatypes() {
		return datatypes;
	}
	
	public List<Object> getArguments() {
		return attributes;
	}
	
	public int getNumberOfArguments() {
		 return attributes.size();
	}
}
