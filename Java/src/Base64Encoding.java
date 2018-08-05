public class Base64Encoding {

	static char[] indexTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".toCharArray();

	public static void main(String[] args) throws InterruptedException {
		System.out.println(encode("AAAAAAAAAAAA"));
		System.out.println(decode(encode("123")));
		System.out.println(decode(encode("1234")));
		System.out.println(decode(encode("12345")));
		System.out.println(decode(encode("123456")));
		System.out.println(decode("QUJDYWJjMTIzWFlaeHl6"));
		System.out.println(decode(encode("This is a string that will be encoded and then decoded. "
				+ "If you can read this, my hand crafted algorithm is working swimingly... "
				+ "Now for some non-Base64 characters: ~~~```<<<()()()$$$$$^^^^^@@@@@()()()>>>```~~~")));
		
	}
	
	public static String encode(String data) {
		int datLen = data.length();
		int remainder = datLen % 3;
		int encLen = (datLen / 3) * 4 + (remainder != 0 ? 4 : 0);
		StringBuffer buffer = new StringBuffer(encLen);
		char[] chunkOut = new char[4];
		char[] chunkIn = new char[3];
		
		for(int i = 0; i < (datLen - remainder); i += 3) {
			data.getChars(i, i + 3, chunkIn, 0);
			chunkOut[0] = indexTable[  chunkIn[0]>>>2 ];
			chunkOut[1] = indexTable[ (chunkIn[0] & 0x03)<<4 | chunkIn[1]>>>4 ];
			chunkOut[2] = indexTable[ (chunkIn[1] & 0x0F)<<2 | chunkIn[2]>>>6 ];
			chunkOut[3] = indexTable[  chunkIn[2] & 0x3F ];
			buffer.append(chunkOut);
		}
		
		if(remainder > 0) {
			data.getChars(datLen - remainder, datLen, chunkIn, 0);
			chunkOut = "====".toCharArray();
			chunkOut[0] = indexTable[  chunkIn[0]>>>2 ];
			if(remainder == 1) {
				chunkOut[1] = indexTable[ (chunkIn[0] & 0x03)<<4 ];
			}
			else if (remainder == 2) {
				chunkOut[1] = indexTable[ (chunkIn[0] & 0x03)<<4 | chunkIn[1]>>>4 ];
				chunkOut[2] = indexTable[ (chunkIn[1] & 0x0F)<<2 ];
			}
			buffer.append(chunkOut);
		}
		
		return buffer.toString();
	}
	
	public static String decode(String encData) {
		int encLen = encData.length();
		int decLen;
		int remainder;
		char[] chunkIn = new char[4];
		char[] chunkOut = new char[3];
		
		remainder = 0;
		if(encData.charAt(encLen-1) == '=') {
			remainder = 2;
			if(encData.charAt(encLen-2) == '=') {
				remainder = 1;
			}
		}
		decLen = ((encLen * 3) / 4) - (remainder > 0 ? (remainder == 2 ? 1 : 2) : 0);
		
		StringBuffer buffer = new StringBuffer(decLen);
		
		for(int i = 0; i < (encLen - 4); i += 4) {
			encData.getChars(i, i + 4, chunkIn, 0);
			chunkOut[0] = (char)((getIndexOf(chunkIn[0])<<2) | (getIndexOf(chunkIn[1])>>>4));
			chunkOut[1] = (char)(0xF0 & (getIndexOf(chunkIn[1])<<4) | 0x0F & (getIndexOf(chunkIn[2])>>>2));
			chunkOut[2] = (char)(0xC0 & (getIndexOf(chunkIn[2])<<6) | 0x3F & (getIndexOf(chunkIn[3])));
			buffer.append(chunkOut);			
		}
		
		encData.getChars(encLen - 4, encLen, chunkIn, 0);
		switch(remainder) {
		case 0: 
			chunkOut[0] = (char)((getIndexOf(chunkIn[0])<<2) | (getIndexOf(chunkIn[1])>>>4));
			chunkOut[1] = (char)(0xF0 & (getIndexOf(chunkIn[1])<<4) | 0x0F & (getIndexOf(chunkIn[2])>>>2));
			chunkOut[2] = (char)(0xC0 & (getIndexOf(chunkIn[2])<<6) | 0x3F & (getIndexOf(chunkIn[3])));
			buffer.append(chunkOut);
			break;
		case 1:
			chunkOut[0] = (char)((getIndexOf(chunkIn[0])<<2) | (getIndexOf(chunkIn[1])>>>4));
			buffer.append(chunkOut[0]);			
			break;
		case 2:
			chunkOut[0] = (char)((getIndexOf(chunkIn[0])<<2) | (getIndexOf(chunkIn[1])>>>4));
			chunkOut[1] = (char)(0xF0 & (getIndexOf(chunkIn[1])<<4) | 0x0F & (getIndexOf(chunkIn[2])>>>2));
			buffer.append(chunkOut[0]);
			buffer.append(chunkOut[1]);
			break;
		}
		
		return buffer.toString();
	}
	
	private static int getIndexOf(char c) {
		for(int i = 0; i < indexTable.length; i++) {
			if(indexTable[i] == c)
				return i;
		}
		return Integer.MIN_VALUE;
	}

}
