package bank_access;

import mware_lib.ObjectReference;

public abstract class ManagerImplBase {

	public abstract String createAccount(String owner, String branch) throws InvalidParamException;
	
	/**
	 * Liefert normal nutzbares Objekt zurueck.<br>
	 * Wenn <code>rawObjectRef</code> ein Stellvertreterobjekt sein soll, dann wird
	 * dieses zurueckgeliefert. <br> 
	 * Wenn <code>rawObjectRef</code> eine direkte Objekt-Referenz
	 * sein soll, dann wird das richtige Objekt zurueckgeliefert.
	 * 
	 * @param rawObjectRef <code>Object</code> Umzuwandelndes Objekt.
	 * @return <code>ManagerImplBase</code> Umgewandeltes Objekt.
	 */
	public static ManagerImplBase narrowCast(Object rawObjectRef) {
		return new ManagerImplementation((ObjectReference) rawObjectRef);
	}
}
