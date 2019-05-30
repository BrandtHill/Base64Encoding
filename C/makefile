CC = gcc

b64 : Base64Encoding.c
	$(CC) -o b64 -O3 Base64Encoding.c
	mv b64.exe b64

linux : Base64Encoding.c
	$(CC) -o b64 -O3 Base64Encoding.c

.PHONY : clean

clean : 
	rm -f b64 *.exe *.core