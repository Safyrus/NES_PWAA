
This file contains commands to 'make' this project.
Normally, you should not have to edit this file.
These not much really to say apart list the available commands.

You should now the 2 most important one:
'make resource' that convert the resources like text and images to data, but not musics (see the sound part of the tutorial for that)
'make' that make the NES file from assembly and data

There are others less important ones but that can still be useful to know:

- 'make (your game name).nes': only make the NES file with a NES 2.0 header
- 'make (your game name)_ines1.nes': only make the NES file with a NES 1.0 header
- 'make clean': do the 3 commands below
- 'make clean_bin': clean the temporary binary files generated
- 'make clean_data': clean the generated assembly data
- 'make clean_tmp': clean other temporary files
- 'make run': shortcut for running the game
- 'make text': convert your text to assembly data
- 'make img': convert your images to assembly data
- 'make photo': convert your photos/evidences to assembly data
- 'make anim': convert your animations to assembly data
- 'make hex': dump the NES file into hexadecimal to a text file
- 'make visual': dump the NES file to an image
- 'make gendoc': generate the documentation of the code
