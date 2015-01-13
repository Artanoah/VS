import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.security.ProtectionDomain;

import com.sun.corba.se.impl.ior.ByteBuffer;


public class main {

	public static void main(String[] args) {
		// TODO Auto-generated method stub

	}

	


	public String getFullClassName(String classFileName) throws IOException {           
		File file = new File(classFileName);
	
	    FileChannel roChannel = new RandomAccessFile(file, "r").getChannel(); 
	    MappedByteBuffer bb = roChannel.map(FileChannel.MapMode.READ_ONLY, 0, (int) roChannel.size());         
	
	    Class<?> clazz = getClass().getClassLoader().defineClass((String)null, bb, (ProtectionDomain)null);
	    return clazz.getName();
	}
}
