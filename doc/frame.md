# Frame format

Note: Each frame is 256\*192 pixels (or 32\*24 tiles) and not 256\*240 (NES resolution)

## RLE INC

RLE INC Table from [NesDev wiki](https://www.nesdev.org/wiki/Tile_compression#RLEINC).

| Value | Meaning                                                                                               |
|-------|-------------------------------------------------------------------------------------------------------|
| 00–3F | LIT: Copy (n+1) bytes from input to output                                                            |
| 40    | END: End of stream                                                                                    |
| 41–7F | SEQ: Read next byte b. Put b, (n−0x3F) times; add 1 to b after each iteration                         |
| 80–9F | DBL: Read next byte b1, and next byte b2. Put b1, (n−0x7D) times; swap b2 and b1 after each iteration |
| A0–FF | RUN: Read byte b. Put b, (0x101−n) times.                                                             |

## File format

- Byte 0: flags.
  ```
  FPTS ..BB
  ||||   ++-- CHR bits for the MMC5 upper CHR Bank bits
  |||+------- is Sprite map present ?
  ||+-------- is Tile map present ?
  |+--------- is Palette present ?
  +---------- 1 = Full frame
              0 = partial frame
  ```

- If palette present:
  - Byte 1-2: palette 0 indices. (background color)
  - Byte 3-4: palette 1 indices. (character primary color)
  - Byte 5-6: palette 2 indices. (character contour color)
  - Byte 7-8: palette 4 indices. (character secondary color)
- Tile map. (RLE INC)
- Sprite map. (RLE INC)

#### Full frame vs Partial frame

A **full frame** contain all the data to draw the frame to the screen.

A **partial frame** contains only the change to apply to the last draw frame.

The 2 types of frame are encoded the same way.
The only difference is that when drawing a tile equal to 0, the partial frame will not draw it and use the previous draw data.
For palette map, it must be equal to 3 to be ignored and use the last data.

### Tile map

The tile map is a structure describing the background tiles to draw from the top left to the bottom right of the screen.
Each tile is a 16-bit number corresponding to a tile in CHR ROM.
The tile map is split into 2 lists of 8-bit number (for compression reason).
The first corresponds to the lower part of the 16-bit numbers, and the second list to the higher part.
The higher bytes contain the palette to use for the tile (bits 6 and 7).

### Sprite map

The sprite map is used to draw sprites (in 8*16 mode).
The structure contains a 4-bytes header follow by a list of bytes corresponding to the sprite index in CHR.
Sprites are drawn as a block with a defined width and height.
A sprite with index of 0 is not drawn.

#### Header

- Byte 0: flags + width.
  ```
  ...w wwww
     | ||||
     +-++++-- width of the sprite block
  ```

- Byte 1: CHR page to use it for the sprites.
- Byte 2: x offset of the sprite block.
- Byte 3: y offset of the sprite block.

#### List

TODO
