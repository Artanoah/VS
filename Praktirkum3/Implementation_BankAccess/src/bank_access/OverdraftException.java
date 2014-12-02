package bank_access;

public class OverdraftException extends Exception {
	
	private static final long serialVersionUID = 1L;

	/**
	 * Erstellt eine neue <code>OverdraftException</code>.
	 * 
	 * @param message <code>String</code> Nachricht der Exception
	 */
	public OverdraftException(String message) {
		super(message);
	}
}
