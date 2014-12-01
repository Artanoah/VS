package name_service;

import static name_service.Constants.COMMAND_REBIND;
import static name_service.Constants.COMMAND_REBIND_OBJECTREFERENCE;

import java.util.HashMap;

public class MessageRebind extends Message {

	private static final long serialVersionUID = 1L;

	public MessageRebind(ObjectReference or) {
		super(COMMAND_REBIND);
		
		objectReferenceAttributes = new HashMap<String, ObjectReference>();
		
		objectReferenceAttributes.put(COMMAND_REBIND_OBJECTREFERENCE, or);
	}

	public ObjectReference getObjectReference() {
		return objectReferenceAttributes.get(COMMAND_REBIND_OBJECTREFERENCE);
	}
}
