package to_be_distributed;

import static to_be_distributed.Constants.COMMAND_REBIND;
import static to_be_distributed.Constants.COMMAND_REBIND_OBJECTREFERENCE;

public class MessageRebind extends Message {

	public MessageRebind(ObjectReference or) {
		super(COMMAND_REBIND);
		
		attributes.put(COMMAND_REBIND_OBJECTREFERENCE, or);
	}

	public ObjectReference getObjectReference() {
		return (ObjectReference) attributes.get(COMMAND_REBIND_OBJECTREFERENCE);
	}
}
