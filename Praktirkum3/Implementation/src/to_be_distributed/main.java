package to_be_distributed;

public class main {

	public static void main(String[] args) {
		TestSend ts = new TestSend();
		TestReceive tr = new TestReceive();
		
		tr.start();
		ts.start();
	}

}
