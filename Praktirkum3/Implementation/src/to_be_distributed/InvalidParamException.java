package to_be_distributed;

public class InvalidParamException extends Exception {
	
	/**
	 * Erstellt eine neue <code>InvalidParamException</code>.
	 * 
	 * @param message <code>String</code> Nachricht der Exception
	 */
	public InvalidParamException(String message) {
		super(message);
	}
}
