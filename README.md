# Phoenix Wright: Ace attorney - NES Demake

<div align="center">
  <img src="data/cartridge/cover_front.png" alt="Phoenix Wright: Ace attorney Demake cartridge">
</div>

## Table of Contents

- [Phoenix Wright: Ace attorney - NES Demake](#phoenix-wright-ace-attorney---nes-demake)
  - [Table of Contents](#table-of-contents)
  - [About The Project](#about-the-project)
    - [The Game](#the-game)
    - [The Engine](#the-engine)
  - [Compile](#compile)
    - [Prerequisite](#prerequisite)
    - [Commands](#commands)
  - [Downloads](#downloads)
    - [Releases build](#releases-build)
    - [Nightly build](#nightly-build)
  - [Emulators](#emulators)
  - [Credits / Disclaimer](#credits--disclaimer)
    - [PWAA](#pwaa)
    - [NES](#nes)
    - [Sound](#sound)
    - [Dialogs](#dialogs)
    - [Visuals](#visuals)
    - [Others](#others)

## About The Project

### The Game

This is an attempt to create a Demake of the first "Phoenix Wright: Ace attorney" (PWAA) game for the NES.

### The Engine

If you want to use the NES visual novel engine (NES-VN) to **make your own visual novels on the NES**, go to the [tutorial section](tutorial/) to learn how to set up your project and run the [NES file](tuto.nes) for learning about the features.

## Compile

### Prerequisite

- **Make**: for executing the Makefile
  (Linux already has it. Link for [Windows](https://gnuwin32.sourceforge.net/packages/make.htm))
- [**CC65**](https://github.com/cc65/cc65): An 6502 C compiler uses to create the binary file used by the NES and the Emulator
- **GCC**: GNU Compiler Collection used to compile C language.
  Linux already has it.
  For Windows, you can use the [compiled executable](c/a.exe).
  If it does not work then you will need to remove it and install GCC with either
  [MinGW](https://sourceforge.net/projects/mingw/files/Installer/mingw-get-setup.exe/download),
  [MinGW64](https://www.mingw-w64.org/) or
  [Cygwin](https://sourceware.org/cygwin/)
- [**Python**](https://www.python.org/) with [all the necessary packages](py/requirements.txt) (after Python is installed, run `pip install -r requirements.txt` in the `py` folder)
- An NES emulator is not needed but recommended (see [Emulator](#emulators))

to test if everything is installed, run in a terminal:

- `make --version`
- `cc65 --version`
- `gcc --version`
- `python --version`

If an error occurred on a software, you either:

- Have not or incorrectly installed it.
- It was not added to your path. (you can always change the [config file](cfg/make_default.cfg))
- Something else has gone wrong.


### Commands

Note: You may need to change some configs in the "cfg" folder to be able to run commands.

Note-2: Commands are run from this folder.

| Commands    | Description         |
|-------------|---------------------|
| `make`      | Compile the game    |
| `make text` | Compile the dialogs |
| `make img`  | Compile the images  |
| `make run`  | Run the game        |

## Downloads

### Releases build

Releases build are ""stable"" version of the fan demake,
you can find those builds at [GitHub Releases](https://github.com/Safyrus/NES_PWAA/releases) page.

### Nightly build

Nightly builds are ""unstable""
version of the fan demake build with GitHub actions by consequence we can't say if it runs,
you can find those builds at [GitHub Actions](https://github.com/Safyrus/NES_PWAA/actions/workflows/build-nes.yaml) page.


## Emulators

Because of the use of the MMC5 mapper and a lot of technical "tricks",
a lot of emulators may not be able to run the game.
Plus, the game is also buggy.

I recommend
playing it on the [Mesen](https://www.mesen.ca/) emulator
because it's the emulator that I use to test & debug the game on,
so it should work fine.
It is also the most accurate emulator that I know
(I can't think of developing on the NES without all of these debugging features).

I will add a list of emulators that are capable of running the game here later.
You can still test the game on emulator that is considered accurate
([List of existing Emulator](https://emulation.gametechwiki.com/index.php/Nintendo_Entertainment_System_emulators)). 

## Credits / Disclaimer

```
Phoenix Wright: Ace Attorney And All Respective Names are Trademark and property of Capcom.
We are not affiliated, associated, authorized, endorsed by,
or in any way officially connected with Capcom,or any of its subsidiaries or its affiliates.
```

### PWAA

Capcom for making the original game.

### NES

- [NesDev](https://www.nesdev.org/wiki/Nesdev_Wiki) of course.
- Nintendo for the NES, I suppose.

### Sound

- [FamiStudio](https://famistudio.org) sound engine by BleuBleu.
- [Nitro Studio 2](https://gota7.github.io/NitroStudio2/) by Gota7. Used for the "midi2sseq.exe".
- [SDATxtract](https://github.com/Oreo639/sdatxtract) by oreo639.

### Dialogs

- This [tutorial](https://gbatemp.net/threads/debuting-10-years-of-phoenix-wright-ace-attorney-script-editor-0-2-1.487226/) by pinet. Used to extract PWAA dialogs in a usable format. Tools used in this:
  - DSBuff by WB3000.
  - Phoenix Wright Script Editor (PWSE) by deufeufeu.
- This [python script](https://github.com/drewler/pwse/blob/master/scriptutils.py) by drewler. Helpful to decipher PWAA text special characters.

### Visuals

- Font based on the [Igiari font](https://caveras.net/#igiari) by [Caveras](https://caveras.net/). Remade the ASCII, hiragana & katakana characters to be 8 pixels tall instead of 16.
- Animations GIFs from the [Court records](court-records.net)
- Sprites converted from [The sprite resource](https://www.spriters-resource.com/ds_dsi/phoenixwrightaceattorney/). Rippers:
  - Trish Rowdy (exclamation).
  - Badassbill (First turnabout).
  - Shoda (Sahwit, Judge, Larry, Mia, Phoenix, Payne, Cutscene, Evidence, Locations).
  - TSP184 (Gavel slam, Action lines, Courtroom).

### Others

- The Definitive NES Black Box Variant Guide (https://blog.watagames.com/2019/01/08/the-definitive-nes-black-box-variant-guide/).
