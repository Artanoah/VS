package to_be_distributed;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class Message implements Serializable {

	private static final long serialVersionUID = 1L;
	private String command;
	protected HashMap<String, String> stringAttributes;
	protected HashMap<String, Integer> integerAttributes;
	protected HashMap<String, ArrayList<String>> stringListAttributes;
	protected HashMap<String, Exception> exceptionAttributes;
	protected HashMap<String, ObjectReference> objectReferenceAttributes;
	
	/**
	 * Erstellt eine generelles <code>Message</code> Objekt.
	 * 
	 * @param command <code>String</code> Kommando der Nachricht
	 */
	public Message(String command) {
		this.command = command;
		this.stringAttributes = new HashMap<String, String>();
		this.integerAttributes = new HashMap<String, Integer>();
		this.stringListAttributes = new HashMap<String, ArrayList<String>>();
		this.exceptionAttributes = new HashMap<String, Exception>();
		this.objectReferenceAttributes = new HashMap<String, ObjectReference>();
	}
	
	/**
	 * Gibt das Kommando der Nachricht zurueck
	 * 
	 * @return <code>String</code> Kommando der Nachricht
	 */
	public String getCommand() {
		return command;
	}
	
	/**
	 * Gibt das Attribut <code>attributeName</code> der Nachricht  als <code>Object</code> zurueck. Wenn das
	 * Attribut nicht existiert, dann wird <code>null</code> zurueckgegeben.
	 * 
	 * @param attributeName <code>String</code> Name des angeforderten Attributes
	 * @return <code>Object/null</code> Attribut als <code>Object</code> wenn das Attribut existiert, <code>null</code> wenn nicht. 
	 */
	public String getStringAttribute(String attributeName) {
		return stringAttributes.get(attributeName);
	}
	
	public Integer getIntegerAttribute(String attributeName) {
		return integerAttributes.get(attributeName);
	}
	
	public ArrayList<String> getStringListAttribute(String attributeName) {
		return stringListAttributes.get(attributeName);
	}
	
	public Exception getExceptionAttribute(String attributeName) {
		return exceptionAttributes.get(attributeName);
	}
	
	public ObjectReference getObjectReferenceAttributes(String attributeName) {
		return objectReferenceAttributes.get(attributeName);
	}
}
