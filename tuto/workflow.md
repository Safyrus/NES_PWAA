# Workflow

The project has specific files and folders that hve special roles.
It is important to know what they are to correctly edit and build the game.
Note that most of the specific names of folders and files can be change in the [config file](#config)

## Folders

### asm

This is where the assembly code reside.
This is the actual code of the game that make it do thing on the NES.

### c

This is where the C code is.
C is only used for image compression instead of Python because of the execution speed gain.

### cfg

This is where the configs files are.
There is the config file `make_default.cfg` for the Makefile and a config folder for "Natural Doc".

### data

This is where every data of the game is stored.
This include images, sounds, text, etc.

### doc

Contain the generated documentation and markdown files describing other things.

### lua

A folder containing lua scripts for debugging in Mesen.

### py

This contain all python scripts.
They scripts mainly convert data to a format understandable by the game.

### vscode

Contain a VScode extension that add synthax highlight to the game text.

## Config

The [config file](cfg/make_default.cfg) can be changed to change programs, folders and data location.

The default config assume that:

- every programs location was added to your OS PATH.
- the folders structure has not been changed.
- that the game data is for PWAA.

You may require to change some things in there,
like the emulator location (I don't think it is on your OS PATH).

## Makefile

The Makefile is used to run commands that compile data and the game and do other small things.
To use it, open a terminal and type `make` followed by the command.
For example: `make resource` make all resources.
You can also execute the "run_make" script instead of opening a terminal.

In general, you want to compile the resource you work on, then compile the nes file and finally run the game.

List of commands:

| command    | descriptions                                              |
| ---------- | --------------------------------------------------------- |
| all        | make all resources and compile NES files                  |
| resource   | make all resources (image, sound, text, etc.)             |
| nes        | compile the NES files                                     |
| run        | run the game                                              |
| text       | compile text                                              |
| font       | compile fonts                                             |
| music      | compile music and sfx                                     |
| img        | compile images                                            |
| img_c      | only the 2nd phase of image compilation one by the C code |
| hex        | hexdump the NES file                                      |
| visual     | conert the NES file into a PNG file                       |
| gendoc     | generate the code documentation                           |
| clean      | clean generated files                                     |
| clean_bin  | clean binary files                                        |
| clean_data | clean assembly data files                                 |
| clean_snif | clean SNIF files                                          |
