using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.IO;

namespace Base64Encoding
{
    class Base64Encoding
    {
        static char[] indexTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".ToCharArray();

        static int[] revTable = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                 0,0,0,0,0,0,0,0,0,0,0,62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,
                                 0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,
                                 0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,0,0,0,0,0};

        static string largeData = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum mi purus,\n"
        + "mollis et pulvinar quis, elementum non felis. Ut bibendum dolor ut mauris tempus, euismod\n"
        + "ultricies odio vulputate. Nunc finibus elit non venenatis maximus. Maecenas in mollis ipsum,\n"
        + "mattis laoreet purus. Sed lacus purus, tempus vel elementum sed, rutrum nec massa. Mauris\n"
        + "mattis libero vitae nunc tempor, eget posuere ipsum molestie. Curabitur semper tempus diam.\n"
        + "Morbi rutrum sollicitudin augue, rhoncus viverra velit volutpat vitae.\r\n";

        static void Main(string[] args)
        {
            Console.WriteLine(Encode("AAAAAAAAAAAA"));
            Console.WriteLine(Encode("AAAAAAAAAAAAA"));
            Console.WriteLine(Encode("AAAAAAAAAAAAAA"));
            Console.WriteLine(Encoding.UTF8.GetString(Decode(Encode("123"))));
            Console.WriteLine(Encoding.UTF8.GetString(Decode(Encode("1234"))));
            Console.WriteLine(Encoding.UTF8.GetString(Decode(Encode("12345"))));
            Console.WriteLine(Encoding.UTF8.GetString(Decode(Encode("123456"))));
            Console.WriteLine(Encoding.UTF8.GetString(Decode("QUJDYWJjMTIzWFlaeHl6")));

            Stopwatch sw = new Stopwatch();
            byte[] largeTest = null;
            
            sw.Start();
            for (int i = 0; i < 1000000; i++) largeTest = Decode(Encode(largeData));
            sw.Stop();

            Console.Write(Encoding.UTF8.GetString(largeTest));
            Console.WriteLine("Total time in seconds: " + sw.Elapsed.TotalSeconds);
            Console.Read();
        }

        public static string Encode(string data) { return Encode(Encoding.UTF8.GetBytes(data)); }

        public static string Encode(byte[] data)
        {
            int datLen = data.Length;
            int remainder = datLen % 3;
            int encLen = (datLen / 3) * 4 + (remainder != 0 ? 4 : 0);
            int i;
            StringBuilder buffer = new StringBuilder(encLen);

            for (i = 0; i < (datLen - remainder); i += 3)
            {
                buffer.Append(indexTable[data[i] >> 2]);
                buffer.Append(indexTable[(data[i] & 0x03) << 4 | data[i + 1] >> 4]);
                buffer.Append(indexTable[(data[i + 1] & 0x0F) << 2 | data[i + 2] >> 6]);
                buffer.Append(indexTable[data[i + 2] & 0x3F]);
            }

            if (remainder == 1) buffer.Append(new char[] { indexTable[data[i] >> 2], indexTable[(data[i] & 0x03) << 4], '=', '=' });
            if (remainder == 2) buffer.Append(new char[] { indexTable[data[i] >> 2], indexTable[(data[i] & 0x03) << 4 | data[i + 1] >> 4], indexTable[(data[i + 1] & 0x0F) << 2], '='});

            return buffer.ToString();
        }

        public static byte[] Decode(string data)
        {
            int encLen = data.Length;
            int remainder = data[encLen - 1] == '=' ? (data[encLen - 2] == '=' ? 1 : 2) : 0;
            int decLen = ((encLen * 3) / 4) + ((remainder - 3) % 3);

            int tmp = remainder + decLen;

            //Tried using MemoryStream (like Java ByteBuffer) but it was about 60% slower than byte array;
            var buffer = new byte[decLen];

            int i, j;
            for (i = j = 0; i < (encLen - 4); i += 4)
            {
                buffer[j++] = ((byte)((revTable[data[i]] << 2) | (revTable[data[i + 1]] >> 4)));
                buffer[j++] = ((byte)(0xF0 & (revTable[data[i + 1]] << 4) | 0x0F & (revTable[data[i + 2]] >> 2)));
                buffer[j++] = ((byte)(0xC0 & (revTable[data[i + 2]] << 6) | 0x3F & (revTable[data[i + 3]])));
            }
            
            buffer[j++] = ((byte)((revTable[data[i]] << 2) | (revTable[data[i + 1]] >> 4)));
            if (remainder == 1) return buffer;
            buffer[j++] = ((byte)(0xF0 & (revTable[data[i + 1]] << 4) | 0x0F & (revTable[data[i + 2]] >> 2)));
            if (remainder == 2) return buffer;
            buffer[j++] = ((byte)(0xC0 & (revTable[data[i + 2]] << 6) | 0x3F & (revTable[data[i + 3]])));
            return buffer;
        }
    }
}
