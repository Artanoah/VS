package to_be_distributed;

public class MessageResolve extends Message {
	
	
	public MessageResolve(String objectName) {
		super("resolve");
		
		attributes.put("objectName", objectName);
	}
	
	public String getObjectName() {
		return (String) attributes.get("objectName");
	}
}
