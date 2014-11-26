package to_be_distributed;

import static to_be_distributed.Constants.COMMAND_REBIND;
import static to_be_distributed.Constants.COMMAND_REBIND_OBJECTREFERENCE;

public class MessageRebind extends Message {

	public MessageRebind(ObjectReference or) {
		super(COMMAND_REBIND);
		
		objectReferenceAttributes.put(COMMAND_REBIND_OBJECTREFERENCE, or);
	}

	public ObjectReference getObjectReference() {
		return objectReferenceAttributes.get(COMMAND_REBIND_OBJECTREFERENCE);
	}
}
