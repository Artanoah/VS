package to_be_distributed;

import static to_be_distributed.Constants.COMMAND_RESOLVEANSWER;
import static to_be_distributed.Constants.COMMAND_RESOLVEANSWER_OBJECTREFERENCE;

public class MessageResolveAnswer extends Message {

	public MessageResolveAnswer(ObjectReference or) {
		super(COMMAND_RESOLVEANSWER);
		
		objectReferenceAttributes.put(COMMAND_RESOLVEANSWER_OBJECTREFERENCE, or);
	}
	
	public ObjectReference getObjectReference() {
		return objectReferenceAttributes.get(COMMAND_RESOLVEANSWER_OBJECTREFERENCE);
	}
}
