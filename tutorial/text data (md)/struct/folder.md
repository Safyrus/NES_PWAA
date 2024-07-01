It may be important for you to know how the project is structured and know where to put your data

# asm folder

This is where the code of the game reside.
You don't need to know anything about it unless you want to modify it.
In that case, maybe go look at the documentation first.

## crt0

There is only 1 line in 1 file that may be important.
The last line of the cr0.asm file include the CHR file (graphic data of the game).
The name of the CHR file to include should be 'your_game_name.chr'.


# cfg

This is where the config file is located
(and also config files for the documentation, but we don't care about that).

You may already know about it if you have compiled the game.
In short: you can config the path of anything necessary to compile the game.

# data

This may be the most important folder to you.
This is where all the source data of the game are store.
you can structure it however you want
(if you change corresponding path in the config file)

You must have a folder containing all the text data and precise an output file for your text,
one JSON file for all evidences,
and 4 JSON files for all animations (1 file per PRG region).
What these files are is better explained in their respective part of the tutorial.

Note that some files must remain where there are.
These files are:
- 'empty.png'
- 'empty_chr.png'
- 'empty_photo.png'
- 'FONT.chr' (you can edit that one)

Note: music data are stored here but need to be exported via FamiStudio (see the sound part of the tutorial for more info)

# doc

Contain the generated documentation and some markdown files describing the code.
If you want more information about how the code works, it's here.

# py and c

Contain scripts and programs to convert all your source data into data that can be throw into a nes file.

# lua

Contain some scripts that can be used by Mesen during gameplay to have additional info on what's going on.
