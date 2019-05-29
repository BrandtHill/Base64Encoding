#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>

char* encode(char*);
char* decode(char*);

char* indexTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
int   revTable[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,
                    0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,
                    0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,0,0,0,0,0};

char* largeData = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum mi purus,\n\
mollis et pulvinar quis, elementum non felis. Ut bibendum dolor ut mauris tempus, euismod\n\
ultricies odio vulputate. Nunc finibus elit non venenatis maximus. Maecenas in mollis ipsum,\n\
mattis laoreet purus. Sed lacus purus, tempus vel elementum sed, rutrum nec massa. Mauris\n\
mattis libero vitae nunc tempor, eget posuere ipsum molestie. Curabitur semper tempus diam.\n\
Morbi rutrum sollicitudin augue, rhoncus viverra velit volutpat vitae.\r\n";

int main(void) {
    struct timeval timeStart, timeStop;
    long i;
    char* largeTest_enc;
    char* largeTest_dec;

    printf("%s\n", encode("AAAAAAAAAAAA"));
    printf("%s\n", encode("AAAAAAAAAAAAA"));
    printf("%s\n", encode("AAAAAAAAAAAAAA"));
    printf("%s\n", decode(encode("123")));
    printf("%s\n", decode(encode("1234")));
    printf("%s\n", decode(encode("12345")));
    printf("%s\n", decode(encode("123456")));
    printf("%s\n", decode("QUJDYWJjMTIzWFlaeHl6"));

    gettimeofday(&timeStart, NULL);
    for (i = 0; i<1000000; i++) {
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
    int encLen = (datLen / 3) * 4 + (remainder ? 4 : 0);
    char* buffer = calloc(encLen + 1, sizeof(char));
    int i,j;
    for (i = j = 0; i < (datLen - remainder); i += 3) {
        buffer[j++]   = indexTable[  data[i]>>2 ];
        buffer[j++] = indexTable[ (data[i]   & 0x03)<<4 | data[i+1]>>4 ];
        buffer[j++] = indexTable[ (data[i+1] & 0x0F)<<2 | data[i+2]>>6 ];
        buffer[j++] = indexTable[  data[i+2] & 0x3F ];
    }
    
    if (remainder) {
        strncpy(buffer + j + 2, "==", 2);
        buffer[j] = indexTable[ data[i]>>2 ];
        buffer[j+1] = indexTable[ (data[i] & 0x03)<<4 ];
        if (remainder == 2) {
            buffer[j+1] = indexTable[ (data[i] & 0x03)<<4 | data[i+1]>>4 ];
            buffer[j+2] = indexTable[ (data[i+1] & 0x0F)<<2 ];
        }
    }
    
    return buffer;
}

char* decode(char* data) {
    int encLen = strlen(data);
    int remainder = data[encLen - 1] == '=' ? (data[encLen - 2] == '=' ? 1 : 2) : 0;
    int decLen = ((encLen * 3) / 4) + (remainder - 3) % 3;
    int i,j;
    char* buffer = calloc(decLen + 1, sizeof(char));

    for (i = j = 0; i < (encLen - 4); i += 4) {
        buffer[j++] = (char)((revTable[data[i]]<<2) | (revTable[data[i + 1]]>>4));
        buffer[j++] = (char)(0xF0 & (revTable[data[i+1]]<<4) | 0x0F & (revTable[data[i+2]]>>2));
        buffer[j++] = (char)(0xC0 & (revTable[data[i+2]]<<6) | 0x3F & (revTable[data[i+3]]));
    }

    buffer[j++] = (char)((revTable[data[i]]<<2) | (revTable[data[i+1]]>>4));
    if (remainder == 1) return buffer;
    buffer[j++] = (char)(0xF0 & (revTable[data[i+1]]<<4) | 0x0F & (revTable[data[i+2]]>>2));
    if (remainder == 2) return buffer;
    buffer[j++] = (char)(0xC0 & (revTable[data[i+2]]<<6) | 0x3F & (revTable[data[i+3]]));
    return buffer;
}