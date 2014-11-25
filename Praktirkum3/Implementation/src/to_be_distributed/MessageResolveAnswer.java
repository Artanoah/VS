package to_be_distributed;

import static to_be_distributed.Constants.*;

public class MessageResolveAnswer extends Message {

	public MessageResolveAnswer(ObjectReference or) {
		super(COMMAND_RESOLVEANSWER);
		
		attributes.put("objectReference", or);
	}
	
	public ObjectReference getObjectReference() {
		return (ObjectReference) attributes.get("objectReference");
	}

}
