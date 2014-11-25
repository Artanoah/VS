package name_service;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;

import to_be_distributed.MessageRebind;
import to_be_distributed.MessageResolve;

public class RunNameService {
	private static int port;
	private static boolean run = true;

	/**
	 * Startet den Nameservice. Dieser antwortet auf die Messages {@link MessageResolve} und {@link MessageRebind}
	 * 
	 * @param args <code>String[]</code> Index 0: Port auf dem der Namesservice laufen wird
	 * @throws ParserConfigurationException
	 * @throws TransformerException
	 * @throws IOException 
	 */
	public static void main(String[] args) throws ParserConfigurationException, TransformerException, IOException {
		port = Integer.parseInt(args[0]);
		
		ServerSocket serverSocket = new ServerSocket(port);
		
		while(run) {
			Socket socket = serverSocket.accept();
			NameServiceThread nst = new NameServiceThread(socket);
		}
	}
}
