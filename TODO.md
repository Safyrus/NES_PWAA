## To-do

- [ ] Make the Project core functionality
  - [ ] Main process loop
  - [ ] Dialog box
  - [ ] Image drawing
  - [ ] Background animation
  - [ ] Sprite animation
  - [ ] Scrolling
  - [ ] Saving
  - [ ] FamiStudio import
- [ ] Make missing game resources:
  - [ ] not there yet.
- [ ] Refine game resources:
  - [ ] Dialogs/scripts.
  - [ ] Background scenes.
  - [ ] Character sprites.
  - [ ] Musics + SFX.
- [ ] Python script documentation.

## Done

- [X] Detail feasibility study. Estimate with real data the size (to the KB) of:
  - [X] Dialogs.
        Results: 795 KB for now (not every ctrl chars) uncompressed, 521 KB with Huffman
        (Not below the 512 KB limit but close enough, so it's OK).
        UPDATE:   With basic LZ compression (3 bit len, 12 bit jmp), can go to ~403 KB.
                  Will need to cut text into block to skip decoding all data to read one line (442 KB with same parameters and block size of 8KB).
                  So: Huffman=local decode + medium compress; LZ=block decode + high compress
  - [X] CHR tiles.
        Results: Will sure be < 1 MB (65 536 tiles). If not, can still replace similar tiles with other tiles.
                 1 or more Fonts, depend on language (96 chars each). UI < 512 tiles.
  - [X] Image data (tiles map + palette).
        Results: 102 Backgrounds (50 Cutscene, 28 Location, 8 Courtroom, 16 Start Cutscene) (~0.9KB each).
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
