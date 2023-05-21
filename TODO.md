## To-do

- [ ] Fix bugs
  - [ ] Encode ACCURATE palette with images
  - [ ] Character sprites being all redrawn for every animation frame
  - [ ] If it is possible in 1 frame, update MMC5 nametable and sprite at the same time
  - [ ] Entire screen glitching when loading the next text data block
  - [/] Glitching background (cause by not changing bank during palette & sprite reading)
- [ ] Visual effects
  - [ ] Scrolling
  - [/] Flash
  - [/] Shake
  - [/] Fade
  - [ ] UI Movement
- [ ] Make the Project core functionality
  - [X] Main process loop
  - [X] Dialog box
  - [X] Image drawing
  - [X] Image Animation
  - [/] Visual effects
  - [ ] Saving
  - [ ] Investigation scene
  - [ ] Court record
- [/] Game resources:
  - [X] Dialogs/scripts.
  - [X] Background scenes.
  - [X] Character sprites.
  - [ ] Photo sprites.
  - [X] Musics.
  - [/] SFX.
- [ ] Refine game resources:
  - [ ] Dialogs/scripts.
  - [ ] Background scenes.
  - [ ] Character sprites.
  - [ ] Musics + SFX.
- [ ] Python script documentation.
- [ ] Assembly documentation.
- [ ] Data structure documentation.
- [ ] Fix cross emulators bugs
  - [ ] MMC5 Scanline not behaving correctly?

## Done

- [X] Play DPCM as SFX.
- [X] Replace FI and FO by FAD.
- [X] Add hiragana & katakana font.
- [X] Add some basic SFX.
- [X] Refactor music to not be limited to 2 banks of data.
- [X] Add a markdown file describing the dialog script 'language'.
- [X] Add names to display with the dialog box.
- [X] Update Makefile
- [X] other text data to test animations, music and backgrounds.
- [X] PWAA cartridge concept art.
- [X] Change music, SFX, text and images for the PWAA data.
- [X] Encode necessary PWAA musics in FamiStudio.
- [X] Refactor palettes encoding.
- [X] The JSON animations files (will still need some rework)
- [X] Cut all needed sprites and convert then to a NES palette.
- [X] A LOT of fixes on PWAA dialogs.
- [X] Script to convert PWAA original dialog to the text format used.
- [X] Basic game resources for the prologue:
  - [X] Dialogs/scripts.
  - [X] Background scenes.
  - [X] Character sprites.
  - [X] Musics.
- [X] Credits for tools and resources.
- [X] A useless script to convert file into images.
- [X] Temporary fix music crashing the game by loading 16K of music bank instead of 8K
- [X] Fix dialog box having graphical glitches when appearing/disappearing (at least it seems)
- [X] Fix images encoding and display not considering MMC5 CHR 'region' (256K block)
- [X] Re-fix no palette update when drawing partial frame for similar tiles with different palettes
- [X] (Kind of fix during refactor) encoding not converting images to tiles with the maximum number of colors
- [X] Refactor image encoding scripts to be more performant (the closest tiles are now calculated with a C program)
- [X] Fix Sprite x position being incorrect, because spr_x buffer wasn't reversed after sprite flickering.
- [X] Add fast-forward dialog button
- [X] Encode ACCURATE sprites with images (Choose to maximize top sprites and cut bottom ones if too many)
- [X] Fix MMC5 nametable updated 1 frame too late/soon when switching animation
- [X] Fix temporary wrong scrolling position when starting the animation because of NMI not acknowledged during the draw animation phase
- [X] Fix dialog box top row using PPU backdrop color
- [X] Fix background tiles overflow when drawing the dialog box
- [X] Fix a temporary wrong CHR bank when switching animation
- [X] Do sprite flickering to kind of "draw more sprites"
- [X] PPU background buffer (enable "instant" background update)
- [X] Fix sprites not disappearing when removing the character
- [X] Fix temporary wrong palette
- [X] Fix image encoding not using the background color for the character
- [X] Fix the first character frame being redrawn entirely
- [X] Fix background drawing every frame when no animation is selected
- [X] Fix encoding garbage sprite tiles for every character (because of the wrong sprite dimension)
- [X] Fix Images having too many sprites
- [X] Fix Shake effect not moving sprites
- [X] Read dialog every frame (and not be slowed by image drawing, for example)
- [X] Add macro to write less and maybe make the code more readable
- [X] Add delay before another input
- [X] Fix palette switch background color applying everywhere
- [X] Fix jump using the wrong flag (wrong argument used in the python script)
- [X] Fix using the wrong bank when decoding text (not saved in var 'mmc5_bank')

- [X] Import FamiStudio

- [X] Fix partial images: wrong tile (because of timing when writing to ext RAM during NMI)
- [X] Fix partial images: missing sprites (because we cleared sprites each time a partial image was draw)
- [X] Fix partial images: wrong sprites bank (It wasn't the wrong bank, but too many sprites that were outside the bank)
- [X] Fix partial images: wrong background tiles corruption (background packet not closed in partial frame subroutine)
- [X] Fix garbage tiles. (writing to wrong nametable, because MMC5 register wasn't correctly set)

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
    - [X] NAM
    - [X] FLH
    - [X] FAD
    - [X] COL
    - [X] BIP
    - [X] MUS
    - [X] SND
    - [ ] PHT
    - [ ] CHR
    - [X] ANI
    - [X] BKG
    - [X] FNT
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

      **UPDATE**: With basic LZ compression (3-bit length, 12-bit jump), can go to ~403 KB.
      Will need to cut text into block to skip decoding all data to read one line (442 KB with same parameters and block size of 8 KB).
      So: Huffman=local decode + medium compress; LZ=block decode + high compress

  - [X] CHR tiles.
        Results: Will sure be < 1 MB (65 536 tiles).
        If not, we can still replace similar tiles with other tiles.
        1 or more Fonts, depend on language (96 chars each).
        UI < 512 tiles.

  - [X] Image data (tiles map + palette).
        Results: 102 Backgrounds (50 Cutscenes, 28 Locations, 8 Courtroom scenes, 16 Start cutscenes) (~0.9 KB each).
        23 Characters (really depends on the character, but maybe ~5 KB each in average).
        42+24 evidence.
        12 standing character sprites and 10 smaller character sprites.
        "Hold it !", "Objection !", "Take That !", title screen and action line backgrounds.
        Compress data with RLE INC.
        The Total size approximates to 256 KB.

  - [X] Code.
        Results: IDK but should be for sure < 64 KB (not many systems to implement).

  - [X] Musics + Sounds.
        Results: 27 musics (IDK but maybe ~2 KB and < 8 KB each), 12 voice clips (2 KB each), 54? SFX (< 1 KB each). Total = ~100 KB.

  - Note: If game resources are too big, can still cut the game into 2 Cartridges (like 2 disc games on the PS1)

- [X] Broad feasibility study. Estimate with knowledge of the NES and fake/pseudo representative data:

  - [X] Cartridge size with full data (must be ≤ 2 MB).
        Results: Vague estimation based on a previous NES project.

  - [X] Graphical fidelity with NES constrains.
        Results: Courtroom scene and 1 Phoenix frame done in Aseprite with NES limitation.

  - [X] Audio fidelity with NES constrains.
        Results: MMC5 remix of PWAA on Internet (e.g.: https://www.youtube.com/watch?v=ejm4_1XoLOU).

  - [X] Project complexity to develop:
        Results: Dialog box, image drawing, static animation, very basic save, FamiStudio, basic inputs.
