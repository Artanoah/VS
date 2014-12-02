package cash_access;

import mware_lib.ObjectReference;

public abstract class TransactionImplBase {
		public abstract void deposit(String accountID, double amount) throws InvalidParamException;
		
		public abstract void withdraw(String accountID, double amount) throws InvalidParamException, OverdraftException;
		
		public abstract double getBalance(String accountID) throws InvalidParamException;
		
		/**
		 * Liefert normal nutzbares Objekt zurueck.<br>
		 * Wenn <code>rawObjectRef</code> ein Stellvertreterobjekt sein soll, dann wird
		 * dieses zurueckgeliefert. <br> 
		 * Wenn <code>rawObjectRef</code> eine direkte Objekt-Referenz
		 * sein soll, dann wird das richtige Objekt zurueckgeliefert.
		 * 
		 * @param rawObjectRef <code>Object</code> Umzuwandelndes Objekt.
		 * @return <code>TransactionImplBase</code> Umgewandeltes Objekt.
		 */
		public static TransactionImplBase narrowCast(Object rawObjectRef) {
			return new TransactionImplementation((ObjectReference) rawObjectRef);
			
		}
}
