package bank_access;

import to_be_distributed.OverdraftException;

public abstract class AccountImplBase {
	
	public abstract void transfer(double amount) throws OverdraftException;
	public abstract double getBalance();
	
	/**
	 * Liefert normal nutzbares Objekt zurueck.<br>
	 * Wenn <code>rawObjectRef</code> ein Stellvertreterobjekt sein soll, dann wird
	 * dieses zurueckgeliefert. <br> 
	 * Wenn <code>rawObjectRef</code> eine direkte Objekt-Referenz
	 * sein soll, dann wird das richtige Objekt zurueckgeliefert.
	 * 
	 * @param rawObjectRef <code>Object</code> Umzuwandelndes Objekt.
	 * @return <code>AccountImplBase</code> Umgewandeltes Objekt.
	 */
	public static AccountImplBase narrowCast(Object rawObjectRef) {
		//TODO
	}
}
