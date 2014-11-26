package to_be_distributed;

import java.io.Serializable;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import bank_access.InvalidParamException;
import cash_access.Transaction;
import mware_lib.Constants;
import mware_lib.NameService;
import mware_lib.ObjectBroker;

public class main {

	public static void main(String[] args) throws InvalidParamException, InterruptedException, cash_access.InvalidParamException {
//		TestSend ts = new TestSend();
//		TestReceive tr = new TestReceive();
//		
//		tr.start();
//		ts.start();
		
		ObjectBroker ob = ObjectBroker.init("localhost", Constants.PORT_NAMESERVICE, true);
		NameService ns = ob.getNameService();
		Transaction t = new Transaction("Steffen");
		ns.rebind(t, "SteffensTransaktion");
		System.out.println("main1: Steffens Guthaben: " + t.getBalance(""));
		t.deposit("", 5.0);
		System.out.println("main1: Steffens Guthaben: " + t.getBalance(""));
		System.out.println("done");

//		while(true) {
//			
//		}
//		MessageCall ms = new MessageCall("Ding", "Dong", new ArrayList<String>());
//		Map<String, Object> map = new HashMap<String, Object>();
//		
//		System.out.println(map instanceof Serializable);
	}

}
