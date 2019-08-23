package main

import (
	"fmt"
	"strings"
  "bytes"
  "time"
)

const indexTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
var revTable = [...]byte {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,
	0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,
	0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,0,0,0,0,0} 

const largeData = `Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum mi purus,
mollis et pulvinar quis, elementum non felis. Ut bibendum dolor ut mauris tempus, euismod
ultricies odio vulputate. Nunc finibus elit non venenatis maximus. Maecenas in mollis ipsum,
mattis laoreet purus. Sed lacus purus, tempus vel elementum sed, rutrum nec massa. Mauris
mattis libero vitae nunc tempor, eget posuere ipsum molestie. Curabitur semper tempus diam.
Morbi rutrum sollicitudin augue, rhoncus viverra velit volutpat vitae.
`

func main() {
  fmt.Println(encodeStr("AAAAAAAAAAAA"))
  fmt.Println(encodeStr("AAAAAAAAAAAAA"))
  fmt.Println(encodeStr("AAAAAAAAAAAAAA"))
  fmt.Printf("%s\n", decode(encodeStr("123")))
  fmt.Printf("%s\n", decode(encodeStr("1234")))
  fmt.Printf("%s\n", decode(encodeStr("12345")))
  fmt.Printf("%s\n", decode(encodeStr("123456")))
  fmt.Printf("%s\n", decode("QUJDYWJjMTIzWFlaeHl6"))

  t0 := time.Now()
  for i := 0; i < 1000000; i++ {
    decode(encodeStr(largeData))
  }
  t1 := time.Since(t0)
  //fmt.Printf("%s\n", decode(encodeStr(largeData)))
  fmt.Println(t1)
}

func encodeStr(data string) string { return encode([]byte(data)) }

func encode(data []byte) string {
	datLen := len(data)
	remainder := datLen % 3
	encLen := (datLen / 3) * 4
	if remainder > 0 { encLen += 4 }
	var buffer strings.Builder
	var i int
	buffer.Grow(encLen)
	for i = 0; i < (datLen - remainder); i += 3 {
		buffer.WriteByte(indexTable[												data[i  ]>>2])
		buffer.WriteByte(indexTable[(data[i  ] & 0x03)<<4 | data[i+1]>>4])
		buffer.WriteByte(indexTable[(data[i+1] & 0x0F)<<2 | data[i+2]>>6])
		buffer.WriteByte(indexTable[ data[i+2] & 0x3F])
	}

	if remainder == 1 { buffer.WriteString(string(indexTable[data[i]>>2]) + string(indexTable[(data[i] & 0x03)<<4]) + "==")}
	if remainder == 2 { buffer.WriteString(string(indexTable[data[i]>>2]) + string(indexTable[(data[i] & 0x03)<<4 | data[i+1]>>4]) + string(indexTable[(data[i+1] & 0x0F)<<2]) + "=")}

	return buffer.String()
}

func decode(dataStr string) []byte {
	data := []byte(dataStr)
	encLen := len(data)
	remainder := 0
	if dataStr[encLen - 1] == 61 {
		if dataStr[encLen - 2] == 61 {
			remainder = 1
		} else { 
			remainder = 2 
		}
	}
	decLen := (encLen * 3) / 4 - (3 - remainder) % 3
	var buffer bytes.Buffer
	var i int
	buffer.Grow(decLen)
	for i = 0; i < (encLen - 4); i += 4 {
		buffer.WriteByte(       (revTable[data[i  ]]<<2) |        (revTable[data[i+1]]>>4))
		buffer.WriteByte(0xF0 & (revTable[data[i+1]]<<4) | 0x0F & (revTable[data[i+2]]>>2))
		buffer.WriteByte(0xC0 & (revTable[data[i+2]]<<6) | 0x3F & (revTable[data[i+3]]   ))
	}

	buffer.WriteByte((revTable[data[i]]<<2) |	(revTable[data[i+1]]>>4))
	if remainder == 1 { return buffer.Bytes() }
	buffer.WriteByte(0xF0 & (revTable[data[i+1]]<<4) | 0x0F & (revTable[data[i+2]]>>2))
	if remainder == 2 { return buffer.Bytes() }
	buffer.WriteByte(0xC0 & (revTable[data[i+2]]<<6) | 0x3F & (revTable[data[i+3]]   ))
	return buffer.Bytes()
}