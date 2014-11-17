package mware_lib;

public class NameService {
	
	/**
	 * Meldet ein beliebiges referenzierbares Objekt beim Namensdienst an.
	 * Wenn schon ein Objekt mit dem selben Namen existiert, wird dieses 
	 * ueberschrieben (es wird keine <code>Exception</code> geworfen!) <br>
	 * Ein so referenziertes Objekt kann von anderen Prozessen die bei
	 * dem selben Namensdienst angemeldet sind per <code>resolve</code>
	 * aufgerufen werden. Dabei ist zu beachten, dass angemeldete Objekte
	 * von sich aus threadsave sein sollten, da mehrere Aufrufe gleichzeitig
	 * darauf stattfinden koennen.
	 * 
	 * @param servant <code>Object</code> Zu bindenes Objekt
	 * @param name <code>String</code> Name unter dem das Objekt beim Namensdienst gebunden werden soll
	 */
	public abstract void rebind(Object servant, String name) {
		//TODO
	}

	/**
	 * Erzeugt eine generische Objektreferenz zum angefragten Namen. 
	 * Der angefragte Name muss ein registriertes Objekt beim <code>NameService</code>
	 * sein.
	 * 
	 * @param name <code>String</code> Name des angefragten Objekts
	 * @return <code>Object</code> Generische Referenz zum angefragten Objekt
	 */
	public abstract Object resolve(String name) {
		//TODO
	}
}
