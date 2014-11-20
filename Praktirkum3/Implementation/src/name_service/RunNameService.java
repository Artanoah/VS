package name_service;

import java.io.File;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

public class RunNameService {

	public static void main(String[] args) throws ParserConfigurationException, TransformerException {
		DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
		
		Document doc = docBuilder.newDocument();
		Element rootElement = doc.createElement("message");
		Attr commandAttr = doc.createAttribute("command");
		commandAttr.setValue("resolveName");
		rootElement.setAttributeNode(commandAttr);
		doc.appendChild(rootElement);
		
		Element port = doc.createElement("port");
		
		rootElement.appendChild(port);
		
		System.out.println(rootElement.getAttribute("command"));
		
		http://stackoverflow.com/questions/1428075/how-to-send-xml-data-through-socket-inputstream
	}
}
