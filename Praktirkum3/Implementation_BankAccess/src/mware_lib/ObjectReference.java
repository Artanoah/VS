package mware_lib;

import java.io.Serializable;

public class ObjectReference implements Serializable {

	private static final long serialVersionUID = 1L;
	String serviceHost;
	int port;
	String name;
	String datatype;
	

	public ObjectReference(String name, String datatype, String serviceHost, int port) {
		this.name = name;
		this.serviceHost = serviceHost;
		this.port = port;
		this.datatype = datatype;
	}
	
	public String getServiceHost() {
		return serviceHost;
	}

	public int getPort() {
		return port;
	}

	public String getName() {
		return name;
	}

	public String getDatatype() {
		return datatype;
	}
}
