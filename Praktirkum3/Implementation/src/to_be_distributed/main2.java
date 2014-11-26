package to_be_distributed;

import bank_access.InvalidParamException;
import cash_access.TransactionImplBase;
import mware_lib.Constants;
import mware_lib.NameService;
import mware_lib.ObjectBroker;

public class main2 {

	public static void main(String[] args) throws InvalidParamException, cash_access.InvalidParamException {
		ObjectBroker ob = ObjectBroker.init("localhost", Constants.PORT_NAMESERVICE, true);
		NameService ns = ob.getNameService();
		Object object = ns.resolve("SteffensTransaktion");
		TransactionImplBase account = TransactionImplBase.narrowCast(object);
		System.out.println("Main2 SteffensBalance: " + account.getBalance(""));
		account.deposit("", 5.0);
		System.out.println("Main2 SteffensBalance: " + account.getBalance(""));
		System.out.println("done2");
	}
}
