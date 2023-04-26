# README

![cartridge](data/cartridge/cover_front.png)

This is an attempt at remaking the first "Phoenix Wright: Ace attorney" (PWAA) game for the NES.

This project is also starting to look like a NES engine for visual novels, apparently.

## Compile

### Prerequisite

- Make
- CC65 (https://github.com/cc65/cc65)
- GCC
- Python with all the necessary package:
  - argparse
  - Pillow
  - numpy

### Commands

Note: You may need to change some configs in the "cfg" folder to be able to run commands.

Compile the game: `make`

Compile the dialogs: `make text`

Compile the images: `make img`

Run the game: `make run`

## Emulators

Because of the use of the MMC5 mapper and a lot of technical "tricks",
a lot of emulators may not be able to run the game.
Plus, the game is also buggy.

I recommend playing it on the Mesen emulator (https://www.mesen.ca/) because it's the emulator that I use to test & debug the game on, so it should work fine.
It is also the most accurate emulator that I know (and I can't think of developing on the NES without all of these debugging features).

I will add a list of emulators that are capable of running the game here later.
You can still test the game on emulator that are considered accurate (https://emulation.gametechwiki.com/index.php/Nintendo_Entertainment_System_emulators). 

## Credits

### PWAA

Capcom for the original game.
Note: `Phoenix Wright: Ace Attorney And All Respective Names are Trademark & © of Capcom.
This project is not associated with Capcom.`

### NES

- [NesDev](https://www.nesdev.org/wiki/Nesdev_Wiki) of course.
- Nintendo for the NES I suppose.

### Sound

- The [FamiStudio](https://famistudio.org) sound engine by BleuBleu.
- [Nitro Studio 2](https://gota7.github.io/NitroStudio2/) by Gota7. Used for the "midi2sseq.exe".
- [SDATxtract](https://github.com/Oreo639/sdatxtract) by oreo639.

### Dialogs

- This [tutorial](https://gbatemp.net/threads/debuting-10-years-of-phoenix-wright-ace-attorney-script-editor-0-2-1.487226/) by pinet. Used to extract PWAA dialogs in a usable format. Tools used in this:
  - DSBuff by WB3000.
  - Phoenix Wright Script Editor (PWSE) by deufeufeu.
- This [python script](https://github.com/drewler/pwse/blob/master/scriptutils.py) by drewler. Helpful to decipher PWAA text special characters.

### Visuals

- Font based on the [Igiari font](https://www.dafont.com/igiari.font) by [Caveras](https://caveras.net/). Change the font to be 8 pixels tall instead of 16. (only ASCII characters).
- Sprites converted from [The sprite resource](https://www.spriters-resource.com/ds_dsi/phoenixwrightaceattorney/). Rippers:
  - Trish Rowdy (exclamation).
  - Badassbill (First turnabout).
  - Shoda (Sahwit, Judge, Larry, Mia, Phoenix, Payne, Cutscene).
  - TSP184 (Gavel slam, Action lines, Courtroom).

### Others

- The Definitive NES Black Box Variant Guide (https://blog.watagames.com/2019/01/08/the-definitive-nes-black-box-variant-guide/).
