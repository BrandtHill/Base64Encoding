const index = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
const reverse = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,
    0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,
    0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,0,0,0,0,0];

const encode = (data) => {
    data = Buffer.from(data, 'utf8')
    let enc = ''
    let i = 0
    let chunk
    while((chunk = data.slice(i, i + 3)).length == 3) {
        enc += 
            index[chunk[0] >>> 2] +
            index[(chunk[0] & 0x03) << 4 | chunk[1] >>> 4] +
            index[(chunk[1] & 0x0F) << 2 | chunk[2] >>> 6] +
            index[chunk[2] & 0x3F]
        i += 3
    }
    if (chunk.length) {
        enc +=
            index[chunk[0] >>> 2] +
            index[(chunk[0] & 0x03) << 4 | chunk[1] >>> 4 ] +
            (chunk[1] ? index[(chunk[1] & 0x0F) << 2] : '=') + '='
    }
    return enc
}

const decode = (data) => {
    let encLen = data.length
    let rem = (data.slice(-2, encLen) == '==') ? 1 : (data.slice(-1, encLen) == '=' ? 2 : 0)
    let decLen = (encLen * 0.75) + (rem - 3) % 3
    let buf = Buffer.alloc(decLen)
    let chunk
    let i = 0
    let j = 0

    while((chunk = data.slice(i, i + 4)) && i < encLen - 4) {
        buf.writeUInt8(reverse[chunk.charCodeAt(0)] << 2 | reverse[chunk.charCodeAt(1)] >>> 4, j++)
        buf.writeUInt8(reverse[chunk.charCodeAt(1)] << 4 & 0xF0 | reverse[chunk.charCodeAt(2)] >>> 2 & 0x0F, j++)
        buf.writeUInt8(reverse[chunk.charCodeAt(2)] << 6 & 0xC0 | reverse[chunk.charCodeAt(3)] & 0x3F, j++)
        i += 4
    }

    buf.writeUInt8(reverse[chunk.charCodeAt(0)] << 2 | reverse[chunk.charCodeAt(1)] >>> 4, j++)
    if (rem == 1) return buf
    buf.writeUInt8(reverse[chunk.charCodeAt(1)] << 4 & 0xF0 | reverse[chunk.charCodeAt(2)] >>> 2 & 0x0F, j++)
    if (rem == 2) return buf
    buf.writeUInt8(reverse[chunk.charCodeAt(2)] << 6 & 0xC0 | reverse[chunk.charCodeAt(3)] & 0x3F, j++)
    return buf
}

console.log(encode(process.argv[2]))
console.log(decode(encode(process.argv[2])).toString())