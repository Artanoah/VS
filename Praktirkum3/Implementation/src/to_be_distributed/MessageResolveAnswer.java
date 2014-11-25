package to_be_distributed;


public class MessageResolveAnswer extends Message {

	public MessageResolveAnswer(ObjectReference or) {
		super("revolveAnswer");
		
		attributes.put("objectReference", or);
	}
	
	public ObjectReference getObjectReference() {
		return (ObjectReference) attributes.get("objectReference");
	}

}
