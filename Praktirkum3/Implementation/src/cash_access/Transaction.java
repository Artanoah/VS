package cash_access;

public class Transaction extends TransactionImplBase {
	
	String accountID;
	double balance;
	
	public Transaction(String accountID) {
		this.accountID = accountID;
		this.balance = 0.0;
	}

	@Override
	public void deposit(String accountID, double amount)
			throws InvalidParamException {
		if(amount < 0) {
			throw new InvalidParamException("Negativer Wert eingezahlt");
		} else {
			balance += amount;
		}
		
	}

	@Override
	public void withdraw(String accountID, double amount)
			throws InvalidParamException, OverdraftException {
		if(amount < 0) {
			throw new InvalidParamException("Negativer Wert abgehoben");
		} else if(amount > balance) {
			throw new OverdraftException("Zu viel abgehoben");
		} else {
			balance -=amount;
		}
	}

	@Override
	public double getBalance(String accountID) throws InvalidParamException {
		return balance;
	}

}
