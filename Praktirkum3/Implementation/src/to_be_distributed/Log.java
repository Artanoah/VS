package to_be_distributed;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;


public class Log {
	private String logName;
	private String fileName;
	private PrintWriter writer;
	
	/**
	 * Initialisiert den Logger mit mit dem FileName logName_log.txt
	 * @param logName bezeichnet den Logger und gibt den Dateinamen an
	 */
	public Log(String logName) {
		this.logName = logName;
		this.fileName = logName + "_log.txt";
		
		try {
			writer = new PrintWriter(fileName);
		} catch (IOException e) {
			System.err.println("LogFile konnte nicht erstellt werden");
		}
	}
	
	/**
	 * Schreibt eine neue Nachricht mit dem Status Info in den Log
	 * @param message Die Nachricht die in den Log geschrieben werden soll
	 */
	public void newInfo(String message) {
		String now = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss").format(new Date());
		writer.println(now);
		writer.println("Info: " + message);
		writer.flush();
	}
	
	/**
	 * Schreibt eine neue Nachricht mit dem Status Warning in den Log
	 * @param message Die Nachricht die in den Log geschrieben werden soll
	 */
	public void newWarning(String message) {
		String now = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss").format(new Date());
		writer.println(now);
		writer.println("Warning: " + message);
		writer.flush();
	}
}
