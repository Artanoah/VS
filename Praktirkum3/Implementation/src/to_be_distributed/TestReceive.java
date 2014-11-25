package to_be_distributed;

import java.io.IOException;
import java.net.ServerSocket;

public class TestReceive extends Thread {

	public void run() {
		
		try {
			SocketConnection sc = new SocketConnection();
			ServerSocket ss = new ServerSocket(50001);
			sc.setSocket(ss.accept());
			MessageCall m = (MessageCall) sc.readMessage();
			System.out.println("EMPFAENGER Antwort: \nEMPFAENGER Command: " + m.getCommand() + "\nEMPFAENGER ObjectName: " + m.getObjectName() + "\nEMPFAENGER MethodName: " + m.getMethodName());
			sc.writeMessage(new MessageCallSucessAnswer("Hans", "Rumba"));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
}
