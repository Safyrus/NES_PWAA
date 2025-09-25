# Installation guide

- [Installation guide](#installation-guide)
  - [Installing the project](#installing-the-project)
    - [Install the prerequisite](#install-the-prerequisite)
      - [Prerequisite for Windows](#prerequisite-for-windows)
      - [Prerequisite for Linux](#prerequisite-for-linux)
      - [Cheking Prerequisite](#cheking-prerequisite)

## Installing the project

### Install the prerequisite

**/!\\ If you don't have them, the project will not work /!\\**

#### Prerequisite for Windows

Follow the [instructions here](windows.md).

#### Prerequisite for Linux

- **Make** & **GCC**: Used to run makefiles and compile C code. These should already be install.
- [**CC65**](https://github.com/cc65/cc65): An 6502 C compiler uses to create the binary file used by the NES and the Emulator.
  (Download link at the end of the Github page)
- [**Python**](https://www.python.org/) with [all the necessary packages](../../py/requirements.txt)
  (after Python is installed, run `pip install -r requirements.txt` in the `py` folder) **(TODO: update requirements)**
- An NES emulator is strongly recommended (see [Emulator](../../README.md#emulators))

#### Cheking Prerequisite

to test if everything is installed, run in a terminal:

- `make --version`
- `cc65 --version`
- `gcc --version`
- `python --version`

if you got no error, then you succesfully installed the prerequisite!
