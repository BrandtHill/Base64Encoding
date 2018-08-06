# Base64Encoding

### Introduction
Hi ya'll.
I decided to implement Base 64 encoding and decoding in several different languages. Base 64 Encoding is a way to represent data in strings whose characters fall within a 64-length (+1) subset of ASCII characters. There are probably better ways to do it, but I wrote the encode/decode algorithms how I imagined they should be done.

### How It Works
The encode and decode functions divide the input and output data strings into chunks and use bitwise operations and bit shifting to divvy them all up appropriately. I started with Java then ported the implementation over to C, Python, then C# so that each of them behaved in mostly the same way. I did a time test on each of them, encoding then decoding a large sample string a million times.

### Results
##### Java    - 12.686 seconds
##### C#      - 48.488 seconds
##### Python  - 4405.452 seconds (73 minutes)
##### C       - 24.487 seconds