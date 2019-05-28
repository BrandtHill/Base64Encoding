import java.nio.ByteBuffer;

public class Base64Encoding {

	static char[] indexTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".toCharArray();
	
	static byte[] revTable = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,
            0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,
            0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,0,0,0,0,0};

	static String largeData = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum mi purus,\n"
			+ "mollis et pulvinar quis, elementum non felis. Ut bibendum dolor ut mauris tempus, euismod\n"
			+ "ultricies odio vulputate. Nunc finibus elit non venenatis maximus. Maecenas in mollis ipsum,\n"
			+ "mattis laoreet purus. Sed lacus purus, tempus vel elementum sed, rutrum nec massa. Mauris\n"
			+ "mattis libero vitae nunc tempor, eget posuere ipsum molestie. Curabitur semper tempus diam.\n"
			+ "Morbi rutrum sollicitudin augue, rhoncus viverra velit volutpat vitae.\r\n";
	
	public static void main(String[] args) {		
		System.out.println(encode("AAAAAAAAAAAA"));
		System.out.println(encode("AAAAAAAAAAAAA"));
		System.out.println(encode("AAAAAAAAAAAAAA"));
		System.out.println(new String(decode(encode("123"))));
		System.out.println(new String(decode(encode("1234"))));
		System.out.println(new String(decode(encode("12345"))));
		System.out.println(new String(decode(encode("123456"))));
		System.out.println(new String(decode("QUJDYWJjMTIzWFlaeHl6")));
		
		long timeStart = System.nanoTime();
		
		byte[] largeTest = null;
		for (int i = 0; i < 1000000; i++) {
			largeTest = decode(encode(largeData));
		} 
		
		long timeEnd = System.nanoTime();
		
		System.out.println(new String(largeTest));
		
		System.out.println("Total time in seconds: " + (timeEnd - timeStart)/1000000000.0);
		
	}
	
	public static String encode(String str) { try { return encode(str.getBytes("UTF-8")); } catch (Exception e) {} }

	public static String encode(byte[] data) {
		int datLen = data.length;
		int remainder = datLen % 3;
		int encLen = (datLen / 3) * 4 + (remainder != 0 ? 4 : 0);
		StringBuffer buffer = new StringBuffer(encLen);
		
		for (int i = 0; i < (datLen - remainder); i += 3) {
			buffer.append(indexTable[  data[i]>>>2 ]);
			buffer.append(indexTable[ (data[i] & 0x03)<<4 | data[i+1]>>>4 ]);
			buffer.append(indexTable[ (data[i+1] & 0x0F)<<2 | data[i+2]>>>6 ]);
			buffer.append(indexTable[  data[i+2] & 0x3F ]);
		}
		
		if (remainder > 0) {
			int i = datLen - remainder;
			buffer.append(indexTable[ data[i]>>>2 ]);
			if (remainder == 1) {
				buffer.append(indexTable[ (data[i] & 0x03)<<4 ]);
				buffer.append("==");
			}
			else if (remainder == 2) {
				buffer.append(indexTable[ (data[i] & 0x03)<<4 | data[i+1]>>>4 ]);
				buffer.append(indexTable[ (data[i+1] & 0x0F)<<2 ]);
				buffer.append('=');
			}
		}

		return buffer.toString();
	}
	
	public static byte[] decode(String data) {
		int encLen = data.length();
		int remainder = data.charAt(encLen - 1) == '=' ? (data.charAt(encLen - 2) == '=' ? 1 : 2) : 0;
		int decLen = ((encLen * 3) / 4) - (remainder > 0 ? (remainder == 2 ? 1 : 2) : 0);
		
		ByteBuffer buffer = ByteBuffer.allocate(decLen);
		
		for (int i = 0; i < (encLen - 4); i += 4) {
			buffer.put((byte)((revTable[data.charAt(i)]<<2) | (revTable[data.charAt(i+1)]>>>4)));
			buffer.put((byte)(0xF0 & (revTable[data.charAt(i+1)]<<4) | 0x0F & (revTable[data.charAt(i+2)]>>>2)));
			buffer.put((byte)(0xC0 & (revTable[data.charAt(i+2)]<<6) | 0x3F & (revTable[data.charAt(i+3)])));
		}
		
		int i = encLen - 4;
		switch (remainder) {
		case 0: 
			buffer.put((byte)((revTable[data.charAt(i)]<<2) | (revTable[data.charAt(i+1)]>>>4)));
			buffer.put((byte)(0xF0 & (revTable[data.charAt(i+1)]<<4) | 0x0F & (revTable[data.charAt(i+2)]>>>2)));
			buffer.put((byte)(0xC0 & (revTable[data.charAt(i+2)]<<6) | 0x3F & (revTable[data.charAt(i+3)])));
			break;
		case 1:
			buffer.put((byte)((revTable[data.charAt(i)]<<2) | (revTable[data.charAt(i+1)]>>>4)));
			break;
		case 2:
			buffer.put((byte)((revTable[data.charAt(i)]<<2) | (revTable[data.charAt(i+1)]>>>4)));
			buffer.put((byte)(0xF0 & (revTable[data.charAt(i+1)]<<4) | 0x0F & (revTable[data.charAt(i+2)]>>>2)));
			break;
		}
		
		return buffer.array();
	}

}
