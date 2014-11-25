package to_be_distributed;

import static to_be_distributed.Constants.*;

public class MessageRebind extends Message {

	public MessageRebind(ObjectReference or) {
		super(COMMAND_REBIND);
		
		attributes.put("objectReference", or);
	}

	public ObjectReference getObjectReference() {
		return (ObjectReference) attributes.get("objectReference");
	}
}
