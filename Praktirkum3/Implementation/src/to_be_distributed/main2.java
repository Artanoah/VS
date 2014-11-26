package to_be_distributed;

import mware_lib.NameService;
import mware_lib.ObjectBroker;

public class main2 {

	public static void main(String[] args) {
		ObjectBroker ob = ObjectBroker.init("localhost", Constants.PORT_NAMESERVICE, true);
		NameService ns = ob.getNameService();
		Object object = ns.resolve("Horst");
		System.out.println("done2");
	}

}
