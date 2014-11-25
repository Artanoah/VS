package to_be_distributed;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class Message implements Serializable {

	private static final long serialVersionUID = 1L;
	private String command;
	protected Map<String, Object> attributes;
	
	/**
	 * Erstellt eine generelles <code>Message</code> Objekt.
	 * 
	 * @param command <code>String</code> Kommando der Nachricht
	 */
	public Message(String command) {
		this.command = command;
		this.attributes = new HashMap<String, Object>();
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
	public Object getAttribute(String attributeName) {
		return attributes.get(attributeName);
	}
	
	/**
	 * Gibt die Map mit allen vorhandenen Attributen als <code>Map<String, Object></code> zurueck.
	 * 
	 * @return <code>Map<String, Object></code> Attribut-Map.
	 */
	public Map<String, Object> getAttributes(){
		return attributes;
	}
}
