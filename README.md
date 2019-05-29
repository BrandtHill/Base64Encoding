# Base64Encoding

### Introduction
Hi y'all.
I decided to implement Base 64 encoding and decoding in several different languages. Base 64 Encoding is a way to represent arbitrary data in strings whose characters fall within a 64-length (+1 for padding) subset of ASCII characters. These aren't meant to be as fast as the standard bitshifting by multiples of 6 algoritm, but rather to compare the relative performace of different languages using my encode/decode algorithm implemented in (mostly) the same way (the bitwise operations are identical for all languages).

### How It Works
The encode and decode functions divide the input and output data into chunks and use bitwise operations to transform them appropriately. I performed a benchmark for each language in which a large 'Lorem Ipsum' paragraph is encoded then decoded one million times. The test was run five times and the fastest was selected. For slower languages, the time was extrapolated.

## Benchmark Results

| Language | Time (s)   | Comments                       |
|----------|------------|--------------------------------|
| C        | 1.078425   | Compiled with -O3              |
| Java     | 3.173457   |                                |
| C#       | 5.4726778  | Ran in Visual Studio (Release) |
| Python   | 15.52048   | Ran with PyPy3                 |
| Elixir   | 83.22      | Used Task.async_stream         |
| Python   | 355.266237 | Ran with Python3 (standard)    |

