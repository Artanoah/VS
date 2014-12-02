package mware_lib;

import static mware_lib.Constants.COMMAND_RESOLVEANSWER;
import static mware_lib.Constants.COMMAND_RESOLVEANSWER_OBJECTREFERENCE;

import java.util.HashMap;

public class MessageResolveAnswer extends Message {

	private static final long serialVersionUID = 1L;

	public MessageResolveAnswer(ObjectReference or) {
		super(COMMAND_RESOLVEANSWER);
		
		objectReferenceAttributes = new HashMap<String, ObjectReference>();
		
		objectReferenceAttributes.put(COMMAND_RESOLVEANSWER_OBJECTREFERENCE, or);
	}
	
	public ObjectReference getObjectReference() {
		return objectReferenceAttributes.get(COMMAND_RESOLVEANSWER_OBJECTREFERENCE);
	}
}
