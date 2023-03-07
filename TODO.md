## To-do

- [ ] Fix bugs
  - [ ] Encode ACCURATE palette with images
  - [ ] Background drawing every frame when no animation is selected
- [ ] Visual effects
  - [ ] Scrolling
  - [ ] Flash
  - [/] Shake
  - [/] Fade
  - [ ] UI Movement
- [ ] Make the Project core functionality
  - [ ] Main process loop
  - [/] Dialog box
  - [/] Image drawing
  - [/] Image Animation
  - [ ] Visual effects
  - [ ] Saving
  - [ ] Investigation scene
  - [ ] Court record
- [ ] Make missing game resources:
  - [ ] not there yet.
- [ ] Refine game resources:
  - [ ] Dialogs/scripts.
  - [ ] Background scenes.
  - [ ] Character sprites.
  - [ ] Musics + SFX.
- [ ] Python script documentation.
- [ ] Assembly documentation.
- [ ] Data structure documentation.

## Done

- [X] Encode garbadge sprite tiles for every character (because of wrong sprite dimension)
- [X] Fix Images having too many sprites
- [X] Fix Shake effect not moving sprites
- [X] Read dialog every frame (and not be slowed by image drawing for example)
- [X] Add macro to write less and maybe make the code more readable
- [X] Add delay before another input
- [X] Fix palette switch background color applying everywhere
- [X] Fix jump using the wrong flag (wrong argument used in the python script)
- [X] Fix wrong bank when decoding text (not saved in var 'mmc5_bank')

- [X] Import FamiStudio

- [X] Fix partial images: wrong tile (because of timing when writing to ext RAM during NMI)
- [X] Fix partial images: missing sprites (because we cleared sprites each time a partial image was draw)
- [X] Fix partial images: wrong sprites bank (It was not the wrong bank, but too many sprites that was outside the bank)
- [X] Fix partial images: wrong background tiles corruption (background packet not closed in partial frame subroutine)
- [X] Fix garbage tiles. (writing to wrong nametable, because MMC5 register was not correctly set)

- [X] Image drawing
  - [X] RLEINC encode (python)
  - [X] RLEINC decoding
  - [X] Scanline IRQ to separate screen into "nothing, image, text, nothing"
  - [X] Frame decoding
  - [X] Frame background drawing
  - [X] Frame sprites drawing
  - [X] Palette update
  - [X] Palette 'split'
  - [X] encode images scripts (python)
  - [X] encode frames scripts (python)
  - [X] Partial frame decoding
  - [X] Character Animation

- [/] Dialog box
  - [X] LZ encode (python)
  - [X] LZ decoding
  - [X] Dialog box drawing
  - [X] Text drawing
  - [X] Special characters
    - [X] END
    - [X] LB 
    - [X] DB 
    - [X] FDB
    - [X] TD 
    - [X] SET
    - [X] CLR
    - [X] SAK
    - [X] SPD
    - [X] DL 
    - [ ] NAM
    - [ ] FLH
    - [X] FI 
    - [X] FO 
    - [X] COL
    - [ ] BC 
    - [X] BIP
    - [X] MUS
    - [ ] SND
    - [ ] PHT
    - [ ] CHR
    - [X] ANI
    - [X] BKG
    - [ ] FNT
    - [X] JMP
    - [X] ACT
    - [ ] BP 
    - [ ] SP 
    - [X] RES
    - [X] RES
    - [X] EVT
    - [X] EXT

- [X] Detail feasibility study. Estimate with real data the size (to the KB) of:

  - [X] Dialogs.
        Results: 795 KB for now (not every ctrl chars) uncompressed, 521 KB with Huffman
        (Not below the 512 KB limit but close enough, so it's OK).

      **UPDATE**: With basic LZ compression (3 bits len, 12 bit jmp), can go to ~403 KB.
      Will need to cut text into block to skip decoding all data to read one line (442 KB with same parameters and block size of 8 KB).
      So: Huffman=local decode + medium compress; LZ=block decode + high compress

  - [X] CHR tiles.
        Results: Will sure be < 1 MB (65 536 tiles). If not, can still replace similar tiles with other tiles.
                 1 or more Fonts, depend on language (96 chars each). UI < 512 tiles.

  - [X] Image data (tiles map + palette).
        Results: 102 Backgrounds (50 Cutscene, 28 Location, 8 Courtroom, 16 Start Cutscene) (~0.9 KB each).
        23 Characters (really depends on the character, but maybe ~5 KB each in average).
        42+24 evidences. 12 standing characters sprites and 10 smaller character sprites.
        "Hold it !", "Objection !", "Take That !", title screen and action line backgrounds.
        Compress data with RLE INC.
        Total size approximate to 256 KB.

  - [X] Code.
        Results: IDK but should be for sure < 64 KB (not many systems to implement).

  - [X] Musics + Sounds.
        Results: 27 musics (IDK but maybe ~2 KB and < 8 KB each), 12 voice clips (2 KB each), 54? SFX (< 1 KB each). Total = ~100 KB.

  - Note: If game resources too big, can still cut the game into 2 Cartridges (like 2 disc game on the PS1)

- [X] Broad feasibility study. Estimate with knowledge of the NES and fake/pseudo representative data the:

  - [X] Cartridge size with full data (must be ≤ 2 MB).
        Results: Vague estimation based on previous NES project.

  - [X] Graphical fidelity with NES constrains.
        Results: Courtroom scene and 1 Phoenix frame done in Aseprite with NES limitation.

  - [X] Audio fidelity with NES constrains.
        Results: MMC5 remix of PWAA on Internet (e.g.: https://www.youtube.com/watch?v=ejm4_1XoLOU).

  - [X] Project complexity to develop:
        Results: Dialog box, image drawing, static animation, very basic save, FamiStudio, basic inputs.
