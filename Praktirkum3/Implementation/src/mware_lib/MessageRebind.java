package mware_lib;

import static mware_lib.Constants.COMMAND_REBIND;
import static mware_lib.Constants.COMMAND_REBIND_OBJECTREFERENCE;

public class MessageRebind extends Message {

	private static final long serialVersionUID = 1L;

	public MessageRebind(ObjectReference or) {
		super(COMMAND_REBIND);
		
		objectReferenceAttributes.put(COMMAND_REBIND_OBJECTREFERENCE, or);
	}

	public ObjectReference getObjectReference() {
		return objectReferenceAttributes.get(COMMAND_REBIND_OBJECTREFERENCE);
	}
}
