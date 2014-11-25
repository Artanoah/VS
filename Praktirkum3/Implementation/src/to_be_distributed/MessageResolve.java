package to_be_distributed;

import static to_be_distributed.Constants.*;

public class MessageResolve extends Message {
	
	
	public MessageResolve(String objectName) {
		super(COMMAND_RESOLVE);
		
		attributes.put("objectName", objectName);
	}
	
	public String getObjectName() {
		return (String) attributes.get("objectName");
	}
}
