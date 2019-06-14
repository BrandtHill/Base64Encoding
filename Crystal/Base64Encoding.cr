require "benchmark"

E_TBL = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
D_TBL = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,0,0,1,2,3,4,5,6,
        7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,0,26,27,28,29,
        30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,0,0,0,0,0] of UInt8

LARGE_DATA = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum mi purus, \
  mollis et pulvinar quis, elementum non felis. Ut bibendum dolor ut mauris tempus, euismod \
  ultricies odio vulputate. Nunc finibus elit non venenatis maximus. Maecenas in mollis ipsum, \
  mattis laoreet purus. Sed lacus purus, tempus vel elementum sed, rutrum nec massa. Mauris \
  mattis libero vitae nunc tempor, eget posuere ipsum molestie. Curabitur semper tempus diam. \
  Morbi rutrum sollicitudin augue, rhoncus viverra velit volutpat vitae.\r\n".bytes

def encode(data)
  String.build(data.size * 2) do |s|
    data.each_slice(3) do |d|
      s << (E_TBL[ (d[0] >> 2) ])
      s << (E_TBL[ ((d[0] & 0x03) << 4) | ((d[1]? || 0) >> 4) ])
      s << (d[1]?.nil? ? '=' : E_TBL[ ((d[1] & 0x0F) << 2) | ((d[2]? || 0) >> 6) ])
      s << (d[2]?.nil? ? '=' : E_TBL[ ((d[2] & 0x3F)) ])
    end
  end
end

def decode(data)
  buffer = Array(UInt8).new(data.size)
  data.each_byte.each_slice(4) do |d|
    buffer.push((((D_TBL[d[0]] << 2)       ) | ((D_TBL[d[1]] >> 4)       )))
    buffer.push((((D_TBL[d[1]] << 4) & 0xF0) | ((D_TBL[d[2]] >> 2) & 0x0F)))
    buffer.push((((D_TBL[d[2]] << 6) & 0xC0) | ((D_TBL[d[3]]     ) & 0x3F)))
  end
  buffer
end

puts encode("AAAAAAAAAAAA".bytes)
puts encode("AAAAAAAAAAAAA".bytes)
puts encode("AAAAAAAAAAAAAA".bytes)
puts decode(encode("123".bytes)).map {|x| x.chr}.join
puts decode(encode("1234".bytes)).map {|x| x.chr}.join
puts decode(encode("12345".bytes)).map {|x| x.chr}.join
puts decode(encode("123456".bytes)).map {|x| x.chr}.join
puts decode("QUJDYWJjMTIzWFlaeHl6").map {|x| x.chr}.join

elapsed_time = Time.measure do
  test = [] of UInt8
  1_000_000.times {
    test = decode(encode(LARGE_DATA))
  }
  puts test.map {|x| x.chr}.join()
end
puts "Total time in seconds: " + elapsed_time.total_seconds.to_s
