index_table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

def encode(data):
    data = bytes(data, 'UTF-8')
    dat_len = len(data)
    remainder = dat_len % 3
    enc_len = int((int(dat_len) / 3) * 4 + (4 if (remainder != 0) else 0))
    
    chunk_in = [''] * 3
    chunk_out = [''] * 4
    buffer = [''] * enc_len

    i = 0
    j = 0
    while i < (dat_len - remainder):
        chunk_in = data[i:i+3]
        chunk_out[0] = index_table[  (chunk_in[0])>>2 ]
        chunk_out[1] = index_table[ ((chunk_in[0]) & 0x03)<<4 | (chunk_in[1])>>4 ]
        chunk_out[2] = index_table[ ((chunk_in[1]) & 0x0F)<<2 | (chunk_in[2])>>6 ]
        chunk_out[3] = index_table[  (chunk_in[2]) & 0x3F ]
        buffer[int(j):int(j+4)] = chunk_out
        i += 3
        j += 4

    if remainder > 0:
        chunk_in = data[(dat_len - remainder):dat_len]
        chunk_out[2:4] = '=='
        chunk_out[0] = index_table[ (chunk_in[0])>>2 ]
        if remainder == 1:
            chunk_out[1] = index_table[ ((chunk_in[0]) & 0x03)<<4 ]
        elif remainder == 2:
            chunk_out[1] = index_table[ ((chunk_in[0]) & 0x03)<<4 | (chunk_in[1])>>4 ]
            chunk_out[2] = index_table[ ((chunk_in[1]) & 0x0F)<<2 ]
        buffer[enc_len - 4: enc_len] = chunk_out

    return "".join(buffer)

def decode(enc_data):
    enc_len = len(enc_data)
    remainder = 0
    if enc_data[enc_len - 1] == '=':
        remainder = 2
        if enc_data[enc_len - 2] == '=':
            remainder = 1
    
    dec_len = int((enc_len * 3) / 4) - (0 if(remainder == 0) else (1 if(remainder == 2) else 2))
    chunk_in = [''] * 4
    chunk_out = [''] * 3
    buffer = [''] * dec_len

    i = 0
    j = 0
    while i < (enc_len - 4):
        chunk_in = enc_data[i:i+4]
        chunk_out[0] = chr((get_index_of(ord(chunk_in[0]))<<2) | (get_index_of(ord(chunk_in[1]))>>4))
        chunk_out[1] = chr(0xF0 & (get_index_of(ord(chunk_in[1]))<<4) | 0x0F & (get_index_of(ord(chunk_in[2]))>>2))
        chunk_out[2] = chr(0xC0 & (get_index_of(ord(chunk_in[2]))<<6) | 0x3F & (get_index_of(ord(chunk_in[3]))))
        
        buffer[int(j):int(j)+4] = chunk_out
        i += 4
        j += 3
    
    chunk_in = enc_data[enc_len-4:enc_len]
    if remainder == 0:
        chunk_out[0] = chr((get_index_of(ord(chunk_in[0]))<<2) | (get_index_of(ord(chunk_in[1]))>>4))
        chunk_out[1] = chr(0xF0 & (get_index_of(ord(chunk_in[1]))<<4) | 0x0F & (get_index_of(ord(chunk_in[2]))>>2))
        chunk_out[2] = chr(0xC0 & (get_index_of(ord(chunk_in[2]))<<6) | 0x3F & (get_index_of(ord(chunk_in[3]))))
        buffer[dec_len-3:dec_len] = chunk_out
    elif remainder == 1:
        chunk_out[0] = chr((get_index_of(ord(chunk_in[0]))<<2) | (get_index_of(ord(chunk_in[1]))>>4))
        buffer[dec_len-1:dec_len] = chunk_out[0:1]
    elif remainder == 2:
        chunk_out[0] = chr((get_index_of(ord(chunk_in[0]))<<2) | (get_index_of(ord(chunk_in[1]))>>4))
        chunk_out[1] = chr(0xF0 & (get_index_of(ord(chunk_in[1]))<<4) | 0x0F & (get_index_of(ord(chunk_in[2]))>>2))
        buffer[dec_len-2:dec_len] = chunk_out[0:2]

    return "".join(buffer)

def get_index_of(val):
    for i in range(len(index_table)):
        if chr(val) == index_table[i]:
            return i
    return
    
def main():
    print(encode("AAAAAAAAAAAA"))
    print(decode(encode("123")))
    print(decode(encode("1234")))
    print(decode(encode("12345")))
    print(decode(encode("123456")))
    print(decode("QUJDYWJjMTIzWFlaeHl6"))
    print(decode(encode("""This is a string that will be encoded and then decoded. 
If you can read this, my hand crafted algorithm is working swimingly...
Now for some non-Base64 characters: ~~~```<<<()()()$$$$$^^^^^@@@@@()()()>>>```~~~""")))

if __name__ == "__main__":
    main()