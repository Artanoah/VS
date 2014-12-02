package mware_lib;

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
	/**
	 * Default Konstruktor f�r den Socket
	 * 
	 */
	public SocketConnection() {
	}
	
	/**
	 * Socket Verbindung aufbauen mit dem Namen des Hosts und dem Port
	 * 
	 * @param hostName Name des Hosts
	 * @param port zum Hostname geh�remder Port
	 */
	public SocketConnection(String hostName, int port) throws UnknownHostException, IOException{
		socket = new Socket(hostName, port);
		socket.setSoTimeout(0);
	}
	
	
	/**
	 * Socket Verbindung aufbauen mit der InetAdresse des Hosts und dem dazugeh�rigen Port
	 * 
	 * @param address wird wenn m�glich zu hostName aufgel�st
	 * @param port zum Host geh�render Port
	 */
	public SocketConnection(InetAddress address, int port) throws UnknownHostException, IOException{
		if (address.getHostName() != null) {
			socket = new Socket(address.getHostName(), port);
		} else
			socket = new Socket(address.getHostAddress(), port);
	}
	
	//#####Setter Getter#####
	/**
	 * Setter um den Socket manuell zu setzen sollte er noch nicht gesetzt sein
	 * @param socket Socket auf den der Socket gesetzt werden soll
	 */
	public void setSocket(Socket socket) {
		if (this.socket == null && socket != null){
			this.socket = socket;
		}
	}
	
	//#####Input initialisieren#####
	/**
	 * Initialisiert den InputStream
	 * @throws IOException
	 */
	private void initializeInput() throws IOException {
		input = socket.getInputStream();
	}
	
	/**
	 * ObjerInputStream initialisieren
	 * @throws IOException
	 */
	private void initializeObjectInput() throws IOException {
		if (input == null){
			initializeInput();
		}
		inputObject = new ObjectInputStream(input);
	}
	
	//#####Output initialisieren#####
	/**
	 * OutputStream initialisieren
	 * @throws IOException
	 */
	private void initializeOutput() throws IOException {
		output = socket.getOutputStream();
	}
	
	/**
	 * ObjectOutputStream initialisieren
	 * @throws IOException
	 */
	private void initializeObjectOutput() throws IOException {
		if (output == null) {
			initializeOutput();
		}
		outputObject = new ObjectOutputStream(output);
	}
	
	//#####Objecte lesen, schreiben#####
	
	/**
	 * Object vom InputStream lesen
	 * @return	Object, gibt das Object zur�ck das auf dem InpuStream liegt
	 * @throws ClassNotFoundException
	 * @throws IOException
	 */
	public Object readObject() throws ClassNotFoundException, IOException {
		
		if (inputObject == null) {
			initializeObjectInput();
		}
		if(inputObject.available() == 0) {
			try {
				Thread.sleep(10);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		
		return inputObject.readObject();
	}

	/**
	 * Object auf den OutptStream schreiben
	 * @param object
	 * @throws IOException
	 */
	public void writeObject(Object object) throws IOException{
		if(outputObject == null){
			initializeObjectOutput();
		}
		outputObject.writeObject(object);
	}
	
	//#####Verbindungsabbau#####
	/**
	 * Sicherstellen, dass alle Verbindungen geschlossen werden
	 * @throws IOException
	 */
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
	
	//##### Read/Write Messages#####
	
	/**
	 * Eine Message vom InputStream lesen
	 * @return	Message die gelesen wurde
	 * @throws ClassNotFoundException
	 * @throws IOException
	 */
	public Message readMessage() throws ClassNotFoundException, IOException{
		return (Message) readObject();
	}
	
	/**
	 * Eine Message auf den OutputStream schreiben
	 * @param message Message die geschrieben werden soll
	 * @throws IOException
	 */
	public void writeMessage(Message message) throws IOException{
		writeObject((Object)message);
	}
	

}
