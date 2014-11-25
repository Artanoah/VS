package to_be_distributed;

import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;

public class SocketConnection {
	
	private Socket socket = null;
	private ObjectInputStream inputObject = null;
	private InputStream input = null;
	private OutputStream output = null;
	private ObjectOutputStream outputObject = null;
	
	
	//#####Socket initialisieren#####
	/*Default Konstruktor für den Socket
	 * 
	 */
	public SocketConnection() {
	}
	
	/*Socket Verbindung aufbauen mit dem Namen des Hosts und dem Port
	 * 
	 * @param hostName Name des Hosts
	 * @param port zum Hostname gehöremder Port
	 */
	public SocketConnection(String hostName, int port) throws UnknownHostException, IOException{
		socket = new Socket(hostName, port);
	}
	
	
	/*Socket Verbindung aufbauen mit der InetAdresse des Hosts und dem dazugehörigen Port
	 * 
	 * @param address wird wenn möglich zu hostName aufgelöst
	 * @param port zum Host gehörender Port
	 */
	public SocketConnection(InetAddress address, int port) throws UnknownHostException, IOException{
		if (address.getHostName() != null) {
			socket = new Socket(address.getHostName(), port);
		} else
			socket = new Socket(address.getHostAddress(), port);
	}
	
	//#####Setter Getter#####
	/*Setter um den Socket manuell zu setzen sollte er noch nicht gesetzt sein
	 * @param socket Socket auf den der Socket gesetzt werden soll
	 */
	public void setSocket(Socket socket) {
		if (this.socket == null && socket != null){
			this.socket = socket;
		}
	}
	
	//#####Input initialisieren#####
	private void initializeInput() throws IOException {
		input = socket.getInputStream();
	}

	private void initializeObjectInput() throws IOException {
		if (input == null){
			initializeInput();
		}
		inputObject = new ObjectInputStream(input);
	}
	
	//#####Output initialisieren#####
	private void initializeOutput() throws IOException {
		output = socket.getOutputStream();
	}
	
	private void initializeObjectOutput() throws IOException {
		if (output == null) {
			initializeOutput();
		}
		outputObject = new ObjectOutputStream(output);
	}
	
	//#####Objecte lesen, schreiben#####
	public Object readObject() throws ClassNotFoundException, IOException {
		if (inputObject == null) {
			initializeObjectInput();
		}
		return inputObject.readObject();
	}

	public void writeObject(Object object) throws IOException{
		if(outputObject == null){
			initializeObjectOutput();
		}
		outputObject.writeObject(object);
	}
	
	//#####Verbindungsabbau#####
	public void closeConnection() throws IOException{
		if(output != null){
			output.close();
		}
		if(outputObject != null){
			outputObject.close();
		}
		if(input != null){
			input.close();
		}
		if(inputObject != null){
			inputObject.close();
		}
		socket.close();
	}
	

}
