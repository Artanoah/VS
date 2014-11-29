package mware_lib;

import static mware_lib.Constants.COMMAND_RESOLVE;
import static mware_lib.Constants.COMMAND_RESOLVE_OBJECTNAME;

import java.util.HashMap;

public class MessageResolve extends Message {
	
	private static final long serialVersionUID = 1L;

	public MessageResolve(String objectName) {
		super(COMMAND_RESOLVE);
		
		stringAttributes = new HashMap<String, String>();
		
		stringAttributes.put(COMMAND_RESOLVE_OBJECTNAME, objectName);
	}
	
	public String getObjectName() {
		return stringAttributes.get(COMMAND_RESOLVE_OBJECTNAME);
	}
}
