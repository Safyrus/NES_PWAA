# Text format

All the text data are **cut into blocks** of fix size (default size of **8 KB**).
Each block is compressed with a simple **LZ encoding**.

Default encoding parameters for LZ are: **jump=4096, length=8**

All characters are encoded with 7 bits with a specific [charset](charset.md).
Each LZ character is 1 or 2 bytes (1 for a 'true' character and 2 for a pointer).

To read a dialog, you need to decode
the entire block that contain it.

The first 2 bytes indicate the size of the block. (Low byte then high byte)

## Pseudo decoding algorithm

```text
# for the entire block of input data
while not end_of_block:
    b1 = next_byte() # read next byte from input

    if b1[7] == 0: # if bit 7 is clear
        print(b1)  # then print the byte as a character

    else: # else this is a pointer
        b2  = next_byte()            # get second byte from input
        len = b1[6..4]               # get the string length
        jmp = ( b1[4..0] << 8 ) + b2 # get the jump size
        str = read_back(jmp, len)    # recover the string
        print(str)                   # print the string
```

Pointer structure:

```text
byte 1(first)  byte 0 (second)
pLll Jjjj      jjjj jjjj
|||| ||||      |||| ||||
|||| ++++------++++-++++-------- Jump
|+++---------------------------- Length
+------------------------------- Is pointer
```

## LZ (Lempel Ziv) encoding

The LZ algorithm uses is simple:
We read the text from start to end,
and when a **repeated substring** is detected, it is **replaced by a pointer** to that substring.

A pointer is a pair of two numbers **(length, jump)**.
The "length" determines the size of the substring.
The "jump" determines how far back it is from the current position.

The algorithm uses 2 parameters, a maximum length and a maximum jump size.
