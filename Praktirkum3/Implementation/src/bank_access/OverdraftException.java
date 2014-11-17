package bank_access;

public class OverdraftException extends Exception {
	
	/**
	 * Erstellt eine neue <code>OverdraftException</code>.
	 * 
	 * @param message <code>String</code> Nachricht der Exception
	 */
	public OverdraftException(String message) {
		super(message);
	}
}
