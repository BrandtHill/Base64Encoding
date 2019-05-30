# Base64Encoding

### Introduction
I implemented Base 64 encoding and decoding in several different languages. Base 64 Encoding is a way to represent arbitrary data in strings whose characters fall within a 64-length (+1 for padding) subset of ASCII characters. These aren't meant to be as fast as the standard bitshifting by multiples of 6 algorithm, but rather to compare the relative performace of different languages using my encode/decode algorithm implemented in (mostly) the same way (the bitwise operations are identical for all languages).

### How It Works
The encode and decode functions divide the input and output data into chunks and use bitwise operations to transform them appropriately. I performed a benchmark for each language in which a large 'Lorem Ipsum' paragraph is encoded then decoded one million times. The test was run five times and the fastest was selected. For slower languages, the time was extrapolated.

## Benchmark Results

| Language   | Time (s) | Comments                       | Encoding Struct  | Decoding Struct   |
|------------|----------|--------------------------------|------------------|-------------------|
| C          | 1.078    | Compiled with gcc -O3          | char *           | char *            |
| Java       | 3.173    |                                | StringBuffer     | ByteBuffer        |
| C#         | 4.585    | Ran in VS 2015, .NET 4.6       | StringBuilder    | byte[]            |
| Python     | 15.52    | Ran with PyPy3                 | List<chr>        | bytearray         |
| Javascript | 22.04    | Ran with Node.js v10           | String           | Buffer            |
| Elixir     | 53.00    | Used Task.async_stream         | bitstring        | bitstring         |
| Python     | 355.3    | Ran with Python3 (standard)    | List<chr>        | bytearray         |

