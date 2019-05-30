import time

index_table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
rev_table = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,
            0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,
            0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,0,0,0,0,0]

largeData = """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum mi purus,
mollis et pulvinar quis, elementum non felis. Ut bibendum dolor ut mauris tempus, euismod
ultricies odio vulputate. Nunc finibus elit non venenatis maximus. Maecenas in mollis ipsum,
mattis laoreet purus. Sed lacus purus, tempus vel elementum sed, rutrum nec massa. Mauris
mattis libero vitae nunc tempor, eget posuere ipsum molestie. Curabitur semper tempus diam.
Morbi rutrum sollicitudin augue, rhoncus viverra velit volutpat vitae.\r\n"""

def encode(data):
    if type(data) is str: data = bytes(data, 'UTF-8')
    dat_len = len(data)
    remainder = dat_len % 3
    enc_len = int((int(dat_len) / 3) * 4 + (4 if (remainder != 0) else 0))
    buffer = [''] * enc_len

    i = 0
    j = 0
    while i < (dat_len - remainder):
        buffer[j] = index_table[  (data[i])>>2 ]
        buffer[j+1] = index_table[ ((data[i]) & 0x03)<<4 | (data[i+1])>>4 ]
        buffer[j+2] = index_table[ ((data[i+1]) & 0x0F)<<2 | (data[i+2])>>6 ]
        buffer[j+3] = index_table[  (data[i+2]) & 0x3F ]
        i += 3
        j += 4

    if remainder > 0:
        buffer[j+2:j+4] = '=='
        buffer[j] = index_table[ (data[i])>>2 ]
        buffer[j+1] = index_table[ ((data[i]) & 0x03)<<4 ]
        if remainder == 2:
            buffer[j+1] = index_table[ ((data[i]) & 0x03)<<4 | (data[i+1])>>4 ]
            buffer[j+2] = index_table[ ((data[i+1]) & 0x0F)<<2 ]

    return ''.join(buffer)

def decode(data):
    enc_len = len(data)
    remainder = (3 - data[-2:].count('=')) % 3
    dec_len = int((enc_len * 3) / 4) - (3 - remainder) % 3
    buffer = bytearray(dec_len)

    i = 0
    j = 0
    while i < (enc_len - 4):
        buffer[j] = (rev_table[ord(data[i])]<<2) | (rev_table[ord(data[i+1])]>>4)
        buffer[j+1] = (rev_table[ord(data[i+1])]<<4) & 0xF0 | (rev_table[ord(data[i+2])]>>2) & 0x0F
        buffer[j+2] = (rev_table[ord(data[i+2])]<<6) & 0xC0 | (rev_table[ord(data[i+3])]) & 0x3F
        i += 4
        j += 3

    buffer[j] = (rev_table[ord(data[i])]<<2) | (rev_table[ord(data[i+1])]>>4)
    if remainder == 1: return buffer
    buffer[j+1] = (rev_table[ord(data[i+1])]<<4) & 0xF0 | (rev_table[ord(data[i+2])]>>2) & 0x0F
    if remainder == 2: return buffer
    buffer[j+2] = (rev_table[ord(data[i+2])]<<6) & 0xC0 | (rev_table[ord(data[i+3])]) & 0x3F
    return buffer
    
def main():
    print(encode('AAAAAAAAAAAA'))
    print(encode('AAAAAAAAAAAAA'))
    print(encode('AAAAAAAAAAAAAA'))
    print(decode(encode('123')))
    print(decode(encode('1234')))
    print(decode(encode('12345')))
    print(decode(encode('123456')))
    print(decode('QUJDYWJjMTIzWFlaeHl6'))

    time_start = time.time()
    for _ in range(1000000): largeTest = decode(encode(largeData))
    time_stop = time.time()
    
    print(largeTest)
    print("Total time in seconds: " + str(time_stop - time_start))
    
if __name__ == "__main__":
    main()