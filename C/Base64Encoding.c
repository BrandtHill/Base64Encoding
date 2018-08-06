#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>

#define TABLELEN 64
#define INT32_MIN (-2147483647 - 1)

char* encode(char*);
char* decode(char*);
int getIndexOf(char);

char* indexTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

char* largeData = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum mi purus,\
mollis et pulvinar quis, elementum non felis. Ut bibendum dolor ut mauris tempus, euismod\
ultricies odio vulputate. Nunc finibus elit non venenatis maximus. Maecenas in mollis ipsum,\
mattis laoreet purus. Sed lacus purus, tempus vel elementum sed, rutrum nec massa. Mauris\
mattis libero vitae nunc tempor, eget posuere ipsum molestie. Curabitur semper tempus diam.\
Morbi rutrum sollicitudin augue, rhoncus viverra velit volutpat vitae.\r\n";

int main(void) {
    struct timeval timeStart, timeStop;
    long i;
    char* largeTest_enc;
    char* largeTest_dec;

    printf("%s\n", encode("AAAAAAAAAAAA"));
    printf("%s\n", decode(encode("123")));
    printf("%s\n", decode(encode("1234")));
    printf("%s\n", decode(encode("12345")));
    printf("%s\n", decode(encode("123456")));
    printf("%s\n", decode("QUJDYWJjMTIzWFlaeHl6"));
    printf("%s\n", decode(encode("This is a string that will be encoded and then decoded.\n
If you can read this, my hand crafted algorithm is working swimingly...\n
Now for some non-Base64 characters: ~~~```<<<()()()$$$$$^^^^^@@@@@()()()>>>```~~~")));

    gettimeofday(&timeStart, NULL);
    for(i = 0; i<1000000; i++){
        largeTest_enc = (char*)encode(largeData);
        largeTest_dec = (char*)decode(largeTest_enc);
        free(largeTest_enc);
        free(largeTest_dec);
    }
    
    gettimeofday(&timeStop, NULL);
    largeTest_enc = (char*)encode(largeData);
    largeTest_dec = (char*)decode(largeTest_enc); 
    printf("%s\n", largeTest_dec);
    printf("Total time in seconds: %lf\n", (timeStop.tv_sec - timeStart.tv_sec) + (timeStop.tv_usec - timeStart.tv_usec)/1000000.0);

}

char* encode(char* data) {
    int datLen = strlen(data);
    int remainder = datLen % 3;
    int encLen = (datLen / 3) * 4 + (remainder != 0 ? 4 : 0);
    char* buffer = malloc(encLen);
    char chunkOut[4] = "";
    char chunkIn[3] = "";
    int i;
    for(i = 0; i < (datLen - remainder); i += 3) {
        strncpy(chunkIn, data + i, 3);
        chunkOut[0] = indexTable[  chunkIn[0]>>2 ];
        chunkOut[1] = indexTable[ (chunkIn[0] & 0x03)<<4 | chunkIn[1]>>4 ];
        chunkOut[2] = indexTable[ (chunkIn[1] & 0x0F)<<2 | chunkIn[2]>>6 ];
        chunkOut[3] = indexTable[  chunkIn[2] & 0x3F ];
        strncpy(buffer + ((i/3)*4), chunkOut, 4);
    }
    
    if(remainder > 0) 
    {
        strncpy(chunkIn, data + (datLen - remainder), remainder);
        strncpy(chunkOut, "====", 4);
        chunkOut[0] = indexTable[  chunkIn[0]>>2 ];
        if(remainder == 1) {
            chunkOut[1] = indexTable[ (chunkIn[0] & 0x03)<<4 ];
        }
        else if (remainder == 2) {
            chunkOut[1] = indexTable[ (chunkIn[0] & 0x03)<<4 | chunkIn[1]>>4 ];
            chunkOut[2] = indexTable[ (chunkIn[1] & 0x0F)<<2 ];
        }
        strncpy(buffer + encLen - 4, chunkOut, 4);
    }
    
    return buffer;
}

char* decode(char* encData) {
    int encLen = strlen(encData);
    int decLen;
    int remainder;
    int i;
    char chunkIn[4] = "";
    char chunkOut[3] = "";
    char* buffer;
    
    remainder = 0;
    if(encData[encLen - 1] == '=') {
        remainder = 2;
        if(encData[encLen-2] == '=') {
            remainder = 1;
        }
    }

    decLen = ((encLen * 3) / 4) - (remainder > 0 ? (remainder == 2 ? 1 : 2) : 0);
    buffer = malloc(decLen);
    
    for(i = 0; i < (encLen - 4); i += 4) {
        strncpy(chunkIn, encData + i, 4);
        chunkOut[0] = (char)((getIndexOf(chunkIn[0])<<2) | (getIndexOf(chunkIn[1])>>4));
        chunkOut[1] = (char)(0xF0 & (getIndexOf(chunkIn[1])<<4) | 0x0F & (getIndexOf(chunkIn[2])>>2));
        chunkOut[2] = (char)(0xC0 & (getIndexOf(chunkIn[2])<<6) | 0x3F & (getIndexOf(chunkIn[3])));
        strncpy(buffer + ((i/4)*3), chunkOut, 3);
    }
    
    strncpy(chunkIn, encData + encLen - 4, 4);
    switch(remainder) {
    case 0: 
        chunkOut[0] = (char)((getIndexOf(chunkIn[0])<<2) | (getIndexOf(chunkIn[1])>>4));
        chunkOut[1] = (char)(0xF0 & (getIndexOf(chunkIn[1])<<4) | 0x0F & (getIndexOf(chunkIn[2])>>2));
        chunkOut[2] = (char)(0xC0 & (getIndexOf(chunkIn[2])<<6) | 0x3F & (getIndexOf(chunkIn[3])));
        strncpy(buffer + decLen - 3, chunkOut, 3);
        break;
    case 1:
        chunkOut[0] = (char)((getIndexOf(chunkIn[0])<<2) | (getIndexOf(chunkIn[1])>>4));		
        buffer[decLen - 1] = chunkOut[0];
        break;
    case 2:
        chunkOut[0] = (char)((getIndexOf(chunkIn[0])<<2) | (getIndexOf(chunkIn[1])>>4));
        chunkOut[1] = (char)(0xF0 & (getIndexOf(chunkIn[1])<<4) | 0x0F & (getIndexOf(chunkIn[2])>>2));
        buffer[decLen - 2] = chunkOut[0];
        buffer[decLen - 1] = chunkOut[1];
        break;
    }
    
    return buffer;
}

int getIndexOf(char c) {
    int i;
    for(i = 0; i < TABLELEN; i++) {
        if(indexTable[i] == c)
            return i;
    }
    return INT32_MIN;
}