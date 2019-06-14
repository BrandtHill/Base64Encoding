import strutils
import times

const ETBL = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
const DTBL = [byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,
            0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,
            0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,0,0,0,0,0]

const largeData = """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum mi purus,
mollis et pulvinar quis, elementum non felis. Ut bibendum dolor ut mauris tempus, euismod
ultricies odio vulputate. Nunc finibus elit non venenatis maximus. Maecenas in mollis ipsum,
mattis laoreet purus. Sed lacus purus, tempus vel elementum sed, rutrum nec massa. Mauris
mattis libero vitae nunc tempor, eget posuere ipsum molestie. Curabitur semper tempus diam.
Morbi rutrum sollicitudin augue, rhoncus viverra velit volutpat vitae.\r\n"""

proc encode(data: string): string =
  let remainder = data.len %% 3
  let enc_len = int((int(data.len) / 3) * 4 + (if (remainder != 0): 4 else: 0))
  var buffer: string

  var i = 0
  var j = 0
  while i < (data.len - remainder):
    buffer &= ETBL[ cast[int](data[i]) shr 2 ]
    buffer &= ETBL[ (cast[int](data[i]) and 0x03) shl 4 or cast[int](data[i+1]) shr 4 ]
    buffer &= ETBL[ (cast[int](data[i+1]) and 0x0F) shl 2 or cast[int](data[i+2]) shr 6 ]
    buffer &= ETBL[  cast[int](data[i+2]) and 0x3F ]
    i += 3
    j += 4

  if remainder > 0:
    buffer &= "===="
    buffer[j] = ETBL[ cast[int](data[i]) shr 2 ]
    buffer[j+1] = ETBL[ (cast[int](data[i]) and 0x03) shl 4 ]
    if remainder == 2:
      buffer[j+1] = ETBL[ (cast[int](data[i]) and 0x03) shl 4 or cast[int](data[i+1]) shr 4 ]
      buffer[j+2] = ETBL[ (cast[int](data[i+1]) and 0x0F) shl 2 ]

  return buffer

proc decode(data: string): string =
  let remainder = if data.endsWith('='): (if data.endsWith("=="): 1 else: 2) else: 0
  let dec_len = int((data.len * 3) / 4) - (3 - remainder) %% 3
  var buffer: string

  var i = 0
  var j = 0
  while i < (data.len() - 4):
    buffer &= cast[char]((DTBL[ord(data[i])] shl 2) or (DTBL[ord(data[i+1])] shr 4))
    buffer &= cast[char]((DTBL[ord(data[i+1])] shl 4) and 0xF0 or (DTBL[ord(data[i+2])] shr 2) and 0x0F)
    buffer &= cast[char]((DTBL[ord(data[i+2])] shl 6) and 0xC0 or (DTBL[ord(data[i+3])]) and 0x3F)
    i += 4
    j += 3

  buffer &= cast[char]((DTBL[ord(data[i])] shl 2) or (DTBL[ord(data[i+1])] shr 4))
  if remainder == 1: return buffer
  buffer &= cast[char]((DTBL[ord(data[i+1])] shl 4) and 0xF0 or (DTBL[ord(data[i+2])] shr 2) and 0x0F)
  if remainder == 2: return buffer
  buffer &= cast[char]((DTBL[ord(data[i+2])] shl 6) and 0xC0 or (DTBL[ord(data[i+3])]) and 0x3F)
  return buffer

echo encode("AAAAAAAAAAAA")
echo "AAAAAAAAAAAAA".encode
echo encode "AAAAAAAAAAAAAA"
echo decode(encode("123"))
echo decode encode "1234"
echo "12345".encode.decode
echo "123456".encode().decode()
echo decode "QUJDYWJjMTIzWFlaeHl6"

var largeTest: string
let time_start = epochTime()
for _ in (1 .. 1_000_000): largeTest = decode(encode(largeData))
let time_stop = epochTime()

echo largeTest
echo "Total time in seconds: ", time_stop - time_start
