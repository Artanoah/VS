package to_be_distributed;

import java.io.Serializable;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import mware_lib.NameService;
import mware_lib.ObjectBroker;

public class main {

	public static void main(String[] args) {
//		TestSend ts = new TestSend();
//		TestReceive tr = new TestReceive();
//		
//		tr.start();
//		ts.start();
		
		ObjectBroker ob = ObjectBroker.init("localhost", Constants.PORT_NAMESERVICE, true);
		NameService ns = ob.getNameService();
		ns.rebind("String", "Horst");
		System.out.println("done");
		
//		MessageCall ms = new MessageCall("Ding", "Dong", new ArrayList<String>());
//		Map<String, Object> map = new HashMap<String, Object>();
//		
//		System.out.println(map instanceof Serializable);
	}

}
