package to_be_distributed;

import static to_be_distributed.Constants.COMMAND_RESOLVE;
import static to_be_distributed.Constants.COMMAND_RESOLVE_OBJECTNAME;

public class MessageResolve extends Message {
	
	
	public MessageResolve(String objectName) {
		super(COMMAND_RESOLVE);
		
		attributes.put(COMMAND_RESOLVE_OBJECTNAME, objectName);
	}
	
	public String getObjectName() {
		return (String) attributes.get(COMMAND_RESOLVE_OBJECTNAME);
	}
}
