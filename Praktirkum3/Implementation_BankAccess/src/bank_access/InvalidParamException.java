package bank_access;

public class InvalidParamException extends Exception {
	
	private static final long serialVersionUID = 1L;

	/**
	 * Erstellt eine neue <code>InvalidParamException</code>.
	 * 
	 * @param message <code>String</code> Nachricht der Exception
	 */
	public InvalidParamException(String message) {
		super(message);
	}
}
