#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

#define TABLELEN 64

char* encode(char*);
char* decode(char*);
int getIndexOf(char);

char* indexTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

int main(void) {
    char* str1 = "AAAAAAAAAAAA";
    char* str2 = "123";
    char* str3 = "1234";
    char* str4 = "12345";
    char* str5 = "123456";
    char* str6 = "QUJDYWJjMTIzWFlaeHl6";
    char* str7 = "This is a string that will be encoded and then decoded. \
            If you can read this, my hand crafted algorithm is working swimingly... \
            Now for some non-Base64 characters: ~~~```<<<()()()$$$$$^^^^^@@@@@()()()>>>```~~~";
    printf("%s\n", encode(str1));
    printf("%s\n", decode(encode(str2)));
    printf("%s\n", decode(encode(str3)));
    printf("%s\n", decode(encode(str4)));
    printf("%s\n", decode(encode(str5)));
    printf("%s\n", decode(str6));
    printf("%s\n", decode(encode(str7)));
}

char* encode(char* data) {
    int datLen = strlen(data);
    int remainder = datLen % 3;
    int encLen = (datLen / 3) * 4 + (remainder != 0 ? 4 : 0);
    char* buffer = malloc(encLen);
    char chunkOut[4] = "";
    char chunkIn[3] = "";
    
    for(int i = 0; i < (datLen - remainder); i += 3) {
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
    char chunkIn[4] = "";
    char chunkOut[3] = "";
    
    remainder = 0;
    if(encData[encLen - 1] == '=') {
        remainder = 2;
        if(encData[encLen-2] == '=') {
            remainder = 1;
        }
    }
    decLen = ((encLen * 3) / 4) - (remainder > 0 ? (remainder == 2 ? 1 : 2) : 0);
    
    char* buffer = malloc(decLen);
    
    for(int i = 0; i < (encLen - 4); i += 4) {
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
    for(int i = 0; i < TABLELEN; i++) {
        if(indexTable[i] == c)
            return i;
    }
    return INT32_MIN;
}