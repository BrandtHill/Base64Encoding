package main

import (
	"fmt"
	"strings"
)

const indexTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
var revTable = [...]int {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,
	0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,
	0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,0,0,0,0,0} 

const largeData = `Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum mi purus,\n
mollis et pulvinar quis, elementum non felis. Ut bibendum dolor ut mauris tempus, euismod\n
ultricies odio vulputate. Nunc finibus elit non venenatis maximus. Maecenas in mollis ipsum,\n
mattis laoreet purus. Sed lacus purus, tempus vel elementum sed, rutrum nec massa. Mauris\n
mattis libero vitae nunc tempor, eget posuere ipsum molestie. Curabitur semper tempus diam.\n
Morbi rutrum sollicitudin augue, rhoncus viverra velit volutpat vitae.\r\n`

func main() {
	fmt.Println("test")
}

func encode(data []uint8) string {
	datLen := len(data)
	remainder := datLen % 3
	encLen := (datLen / 3) * 4
	if remainder > 0 { encLen += 4 }
	var buffer strings.Builder
	var i int
	buffer.Grow(encLen)
	for i = 0; i < (datLen - remainder); i += 3 {
		buffer.WriteString(indexTable[												data[i  ]>>2])
		buffer.WriteString(indexTable[(data[i  ] & 0x03)<<4 | data[i+1]>>4])
		buffer.WriteString(indexTable[(data[i+1] & 0x0F)<<2 | data[i+2]>>6])
		buffer.WriteString(indexTable[ data[i+2] & 0x3F])
	}

	if remainder == 1 { buffer.WriteString(string(indexTable[data[i]>>2]) + string(indexTable[(data[i] & 0x03)<<4]) + "==")}
	if remainder == 2 { buffer.WriteString(string(indexTable[data[i]>>2]) + string(indexTable[(data[i] & 0x03)<<4 | data[i+1]>>4]) + string(indexTable[(data[i+1] & 0x0F)<<2]) + "=")}

	return buffer.String()
}

func decode(dataStr string) []uint8 {
	data := []uint8(dataStr)
	encLen := len(data)
	//remainder := (3 - data[encLen - 2 : encLen] )[encLen - 1]
}