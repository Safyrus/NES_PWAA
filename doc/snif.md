# SNIF (Safyrus NES Image Format)

Image file format for the NES with the MMC5 mapper.

File = metadata + data + tiles.
data in PRG.
tiles in CHR.

## Meta data

not present when on hardware.
Use in real file to indicate/simulate info about hardware.
metadata format = JSON data.
data follow just after metadata.

Meta Info:

- `version` : version number
- `mapper` : INES mapper id
- `nbimg` : Number of images present
- `hashori` : Original Image hash (done in python with `hashlib.sha256(Image.open(path).tobytes()).hexdigest()`)
- Any other key value

## Data

Format for 1 image:

- byte 0
- byte 1
- palettes
- PPU CHR banks
- BKG data
- SPR data

next image data follow just after.
last image is followed by CHR.

### Byte 0

```text
brrwwwww
|||+++++--  **W**idth (in tile) + 1.
|++-------  CHR rom **R**egion
+---------  **B**ackground data is compressed (1) or not (0)
```

### Byte 1

```text
000hhhhh
|||+++++--  **H**eight (in tile) + 1. Value 30 & 31 are invalid.
+++-------  Reserved for futur, should be set to 0
```

### Palettes

$3F color = no color / data / don't replace current color

First byte:

```text
n0bbbbbb
||++++++--  **B**ackground/**B**ackdrop color
|+--------  Reserved for futur, should be set to 0
+---------  **N** Next data is palette
```

3 bytes for each palette:

```text
byte 0   byte 1   byte 2
nbffffff ppssssss 00tttttt
|||||||| |||||||| ||++++++--  **T**hird color (index 3 in NES palette)
|||||||| |||||||| ++--------  Reserved for futur, should be set to 0
|||||||| ||++++++-----------  **S**econD color (index 2 in NES palette)
|||||||| ++-----------------  **P**alette index
||++++++--------------------  **F**irst color (index 1 in NES palette)
|+--------------------------  **B**ackground (0) or sprite (1) palette
+---------------------------  **N** Next data is palette
```

### PPU CHR banks

1 mask byte to know which PPU bank to change
bit 0 = first PPU CHR bank ($0000-$03FF).
bit 7 = last PPU CHR bank ($1C00-$1FFF).

1 byte for each bank.
Value = bank index in region.
Fill first bank indicated by mask.

### BKG Data

- array of MMC5 tile address (low)
- array of MMC5 tile address (high)

Each array is compressed separately with [RLEINC](#rleinc)
if compress flag is set in [byte 0](#byte-0).

Special values:

- tile 0 + palette 0 = empty tile
- tile 0 + palette 1 = reserved
- tile 0 + palette 2 = reserved
- tile 0 + palette 3 = reserved

### SPR Data

- list of sprite/commands

Sprite:

```text
Byte 0:
1xxxyyyy
||||++++--  **Y** offset from tile
|+++------  **X** offset from tile
+---------  **1** = data is sprite

Byte 1:
ssssssss
++++++++--  **S**prite tile index in PPU CHR
```

Command:

```text
Byte0:
0ccccccc
|+++++++--  **C**ommand
+---------  **0** = data is command

Byte 1-?: Depend on command
```

## Sprite Commands

| code  | name | Argument | description                              |
| :---: | :--- | -------- | :--------------------------------------- |
|  $00  | END  |          | end of data stream                       |
|  $01  |      |          | unused                                   |
|  $02  | BKG  |          | put next sprites in background           |
|  $03  | FRG  |          | put next sprites in foreground           |
|  $04  | F__  |          | clear next sprites flip                  |
|  $05  | F_H  |          | set next sprites h flip and clear v flip |
|  $06  | FV_  |          | set next sprites v flip and clear h flip |
|  $07  | FVH  |          | set both next sprites h & v flip         |
|  $08  | PAL0 |          | use palette 0 for next sprites           |
|  $09  | PAL1 |          | use palette 1 for next sprites           |
|  $0A  | PAL2 |          | use palette 2 for next sprites           |
|  $0B  | PAL3 |          | use palette 3 for next sprites           |
|  $0C  | POS0 | position | reposition to XY tile (top left)         |
|  $0D  | POS1 | position | reposition to XY tile (top right)        |
|  $0E  | POS2 | position | reposition to XY tile (bot left)         |
|  $0F  | POS3 | position | reposition to XY tile (bot right)        |

`position` = `xxxxyyyy`.
x & y are low part of position,
high bit of position is implied by command.

## RLEINC

This variant of RLEINC is close to the one found on the NesDev wiki (<https://www.nesdev.org/wiki/Tile_compression>).
The only change is that the LIT command read bytes forwards instead of backwards.

| Value | Meaning                                                                                               |
| ----- | ----------------------------------------------------------------------------------------------------- |
| 00-3F | LIT: Copy (n+1) bytes from input to output                                                            |
| 40    | END: End of stream                                                                                    |
| 41-7F | SEQ: Read next byte b. Put b, (n-0x3F) times; add 1 to b after each iteration                         |
| 80-9F | DBL: Read next byte b1, and next byte b2. Put b1, (n-0x7D) times; swap b2 and b1 after each iteration |
| A0-FF | RUN: Read byte b. Put b, (0x101-n) times.                                                             |
