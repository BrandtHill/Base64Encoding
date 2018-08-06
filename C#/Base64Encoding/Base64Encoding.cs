using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;

namespace Base64Encoding
{
    class Base64Encoding
    {
        static char[] indexTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".ToCharArray();

        static string largeData = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum mi purus,\n"
        + "mollis et pulvinar quis, elementum non felis. Ut bibendum dolor ut mauris tempus, euismod\n"
        + "ultricies odio vulputate. Nunc finibus elit non venenatis maximus. Maecenas in mollis ipsum,\n"
        + "mattis laoreet purus. Sed lacus purus, tempus vel elementum sed, rutrum nec massa. Mauris\n"
        + "mattis libero vitae nunc tempor, eget posuere ipsum molestie. Curabitur semper tempus diam.\n"
        + "Morbi rutrum sollicitudin augue, rhoncus viverra velit volutpat vitae.\r\n";

        static void Main(string[] args)
        {
            Console.WriteLine(Encode("AAAAAAAAAAAA"));
            Console.WriteLine(Decode(Encode("123")));
            Console.WriteLine(Decode(Encode("1234")));
            Console.WriteLine(Decode(Encode("12345")));
            Console.WriteLine(Decode(Encode("123456")));
            Console.WriteLine(Decode("QUJDYWJjMTIzWFlaeHl6"));
            Console.WriteLine(Decode(Encode("This is a string that will be encoded and then decoded.\n"
                    + "If you can read this, my hand crafted algorithm is working swimingly...\n"
                    + "Now for some non-Base64 characters: ~~~```<<<()()()$$$$$^^^^^@@@@@()()()>>>```~~~")));

            Stopwatch sw = new Stopwatch();
            string largeTest = null;
            sw.Start();
            for(int i = 0; i < 1000000; i++)
            {
                largeTest = Decode(Encode(largeData));
            }
            sw.Stop();
            Console.Write(largeTest);
            Console.WriteLine("Total time in seconds: " + sw.Elapsed.TotalSeconds);

            Console.Read();
        }

        public static string Encode(string data)
        {
            int datLen = data.Length;
            int remainder = datLen % 3;
            int encLen = (datLen / 3) * 4 + (remainder != 0 ? 4 : 0);
            StringBuilder buffer = new StringBuilder(encLen);
            char[] chunkOut = new char[4];
            char[] chunkIn = new char[3];

            for (int i = 0; i < (datLen - remainder); i += 3)
            {
                data.CopyTo(i, chunkIn, 0, 3);
                chunkOut[0] = indexTable[chunkIn[0] >> 2];
                chunkOut[1] = indexTable[(chunkIn[0] & 0x03) << 4 | chunkIn[1] >> 4];
                chunkOut[2] = indexTable[(chunkIn[1] & 0x0F) << 2 | chunkIn[2] >> 6];
                chunkOut[3] = indexTable[chunkIn[2] & 0x3F];
                buffer.Append(chunkOut);
            }

            if (remainder > 0)
            {
                data.CopyTo(datLen - remainder, chunkIn, 0, remainder);
                chunkOut = "====".ToCharArray();
                chunkOut[0] = indexTable[chunkIn[0] >> 2];
                if (remainder == 1)
                {
                    chunkOut[1] = indexTable[(chunkIn[0] & 0x03) << 4];
                }
                else if (remainder == 2)
                {
                    chunkOut[1] = indexTable[(chunkIn[0] & 0x03) << 4 | chunkIn[1] >> 4];
                    chunkOut[2] = indexTable[(chunkIn[1] & 0x0F) << 2];
                }
                buffer.Append(chunkOut);
            }

            return buffer.ToString();
        }

        public static string Decode(string encData)
        {
            int encLen = encData.Length;
            int decLen;
            int remainder;
            char[] chunkIn = new char[4];
            char[] chunkOut = new char[3];

            remainder = 0;
            if (encData[encLen - 1] == '=')
            {
                remainder = 2;
                if (encData[encLen - 2] == '=')
                {
                    remainder = 1;
                }
            }
            decLen = ((encLen * 3) / 4) - (remainder > 0 ? (remainder == 2 ? 1 : 2) : 0);

            StringBuilder buffer = new StringBuilder(decLen);

            for (int i = 0; i < (encLen - 4); i += 4)
            {
                encData.CopyTo(i, chunkIn, 0, 4);
                chunkOut[0] = (char)((Array.IndexOf(indexTable, chunkIn[0]) << 2) | (Array.IndexOf(indexTable, chunkIn[1]) >> 4));
                chunkOut[1] = (char)(0xF0 & (Array.IndexOf(indexTable, chunkIn[1]) << 4) | 0x0F & (Array.IndexOf(indexTable, chunkIn[2]) >> 2));
                chunkOut[2] = (char)(0xC0 & (Array.IndexOf(indexTable, chunkIn[2]) << 6) | 0x3F & (Array.IndexOf(indexTable, chunkIn[3])));
                buffer.Append(chunkOut);
            }

            encData.CopyTo(encLen - 4, chunkIn, 0, 4);
            switch (remainder)
            {
                case 0:
                    chunkOut[0] = (char)((Array.IndexOf(indexTable, chunkIn[0]) << 2) | (Array.IndexOf(indexTable, chunkIn[1]) >> 4));
                    chunkOut[1] = (char)(0xF0 & (Array.IndexOf(indexTable, chunkIn[1]) << 4) | 0x0F & (Array.IndexOf(indexTable, chunkIn[2]) >> 2));
                    chunkOut[2] = (char)(0xC0 & (Array.IndexOf(indexTable, chunkIn[2]) << 6) | 0x3F & (Array.IndexOf(indexTable, chunkIn[3])));
                    buffer.Append(chunkOut);
                    break;
                case 1:
                    chunkOut[0] = (char)((Array.IndexOf(indexTable, chunkIn[0]) << 2) | (Array.IndexOf(indexTable, chunkIn[1]) >> 4));
                    buffer.Append(chunkOut[0]);
                    break;
                case 2:
                    chunkOut[0] = (char)((Array.IndexOf(indexTable, chunkIn[0]) << 2) | (Array.IndexOf(indexTable, chunkIn[1]) >> 4));
                    chunkOut[1] = (char)(0xF0 & (Array.IndexOf(indexTable, chunkIn[1]) << 4) | 0x0F & (Array.IndexOf(indexTable, chunkIn[2]) >> 2));
                    buffer.Append(chunkOut[0]);
                    buffer.Append(chunkOut[1]);
                    break;
            }

            return buffer.ToString();
        }
    }
}
