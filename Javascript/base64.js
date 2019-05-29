const index = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
const reverse =[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,
    0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,
    0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,0,0,0,0,0];

const encode = (data) => {
    console.log(data)
    data = Buffer.from(data, 'utf8')
    console.log(data)
    let enc = ''
    let i = 0
    let chunk
    while((chunk = data.slice(i, i + 3)).length == 3) {
        console.log('In Loop: ' + chunk)
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
            chunk[1] ? index[(chunk[1] & 0x0F) << 2] : '=' +
            '='
    }

    return enc
}

const decode = (data) => {
    
}

console.log(encode(process.argv[2]))