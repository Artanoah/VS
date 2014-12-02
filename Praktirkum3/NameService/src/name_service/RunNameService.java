package name_service;

import static name_service.Constants.PORT_NAMESERVICE;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.HashMap;
import java.util.Map;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;

import mware_lib.MessageRebind;
import mware_lib.MessageResolve;
import mware_lib.ObjectReference;

public class RunNameService {
	private static int port;
	private static boolean run = true;
	private static Map<String, ObjectReference> referenceMap;
	private static Log log = new Log("RunNameService");

	/**
	 * Startet den Nameservice. Dieser antwortet auf die Messages {@link MessageResolve} und {@link MessageRebind}
	 * 
	 * @param args <code>String[]</code> Index 0: Port auf dem der Namesservice laufen wird
	 * @throws ParserConfigurationException
	 * @throws TransformerException
	 * @throws IOException 
	 */
	public static void main(String[] args) throws ParserConfigurationException, TransformerException, IOException {
		
		if(args.length >= 1) { 
			port = Integer.parseInt(args[0]);
		} else {
			port = PORT_NAMESERVICE;
		}
		
		ServerSocket serverSocket = new ServerSocket(port);
		referenceMap = new HashMap<String, ObjectReference>();
		
		while(run) {
			Socket socket = serverSocket.accept();
			NameServiceThread nst = new NameServiceThread(socket);
			nst.start();
			log.newInfo("Neuer NameServiceThread wurde gestartet.");
		}
		
		serverSocket.close();
	}
	
	public static synchronized void put(String name, ObjectReference or) {
		referenceMap.put(name, or);
	}
	
	public static synchronized ObjectReference get(String name) {
		return referenceMap.get(name);
	}
}
