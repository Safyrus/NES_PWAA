# Text format

All the text data are **cut into blocks** of fix size (default size of 8 KB).
Each block is compress with a simple **LZ encoding**.

Default encoding parameters for LZ are: **jump=4096, length=8**

All character are encoded with 7 bits with a specific [charset](charset.md). There however use 8 bits for simplicity.

To read a dialog, you need to decode the block from the start to the position of your string.

The first 2 bytes indicate the size of the block. (low byte then high byte)

## Pseudo decoding algorithm

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

Pointer structure:

    byte 1(first)  byte 0 (second)
    pLll Jjjj      jjjj jjjj
    |||| ||||      |||| ||||
    |||| ++++------++++-++++-------- Jump
    |+++---------------------------- Length
    +------------------------------- Is pointer

## LZ (Lempel Ziv) encoding

The LZ algorithm use is simple:
We read the text from start to end and when a **repeated substring** is detected, it is **replaced by a pointer** to that substring.

A pointer is a pair of two number **(length, jump)**.
The "length" determine the size of the substring.
The "jump" determine how far back it is from the current position.

The algorithm use 2 parameters, a maximum length and a maximum jump size.
