package to_be_distributed;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;

public class TestSend extends Thread {

	public void run() {
		try {
			SocketConnection sc = new SocketConnection(InetAddress.getLocalHost(), 50001);
			sc.writeMessage(new MessageCall("horst", "tanzen"));
			Message m = sc.readMessage();
			System.out.println("SENDER: Antwort: \nSENDER Command: " + m.getCommand() + "\nSENDER Value: " + ((String) m.getAttribute("answer")));
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
