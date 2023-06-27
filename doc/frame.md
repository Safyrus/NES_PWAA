# Frame format

Note: Each frame is 256\*192 pixels (or 32\*24 tiles) and not 256\*240 pixels (NES resolution)

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

- If palette flag: palettes data.
- If tile map flag: tile map (RLE INC).
- If sprite map flag: sprite map (RLE INC).

#### Full frame vs Partial frame

A **full frame** contain all the data to draw the frame to the screen.

A **partial frame** contains only the change to apply to the last draw frame.

The 2 types of frame are encoded the same way.
The only difference is that when drawing a tile equal to 0 (low part or high part), the partial frame will not draw it and use the previous draw data.

### Palettes

Each byte correspond to a NES color plus 2 bits to indicate what palette to change.
To indicate the position in the palette, a counter is used. It starts at 0 and increment each time a color is written.
A value of $FF indicate the end of data.

```
ppcc cccc
||++-++++-- color
++--------- palette index (0=background, 1=character, 2=sprites)
```

### Tile map

The tile map is a structure describing the background tiles to draw from the top left to the bottom right of the screen.
Each tile is a 16-bit number corresponding to a tile in CHR ROM.
The tile map is split into 2 lists of 8-bit number (for compression reason).
The first corresponds to the lower part of the 16-bit numbers, and the second list to the higher part.
The higher bytes contain the palette to use for the tile (bits 6 and 7).

### Sprite map

The sprite map is used to draw sprites (in 8*16 mode).
The structure contains a 4-bytes header follow by a list of bytes corresponding to the sprite index in CHR.
Sprites are drawn as a "mega-sprite", a block of sprites with a defined width and height, at a defined (x,y) offset.
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

#### Example

This data:

```
      header    list of sprite index
data: [w,p,x,y] [1,2,3,4,5,6,7,8,9,10,11,12]
```

Will give this on the screen:

```
           y
 +------------------------------------------------+
 |         |                                      |
 |                                                |
 |         |                                      |
 |                 w                              |
 |         |<------------->                       |
x|- - - - -################ ^                     |
 |         # 1  # 2  # 3  # |                     |
 |         ################ |                     |
 |         # 4  # 5  # 6  # |                     |
 |         ################ | h (list size / w)   |
 |         # 7  # 8  # 9  # |                     |
 |         ################ |                     |
 |         # 10 # 11 # 12 # |                     |
 |         ################ v                     |
 |                                                |
 |                                                |
 |                                                |
 +------------------------------------------------+
```
