# Text config

For text data configs ("cfg/make_default.cfg"),
you only need to specify a folder where all of your text is located
and an output text file where all of your text will be merged.

## Folder

For now, all file in the input folder will be sorted and merge alphabetically.
This mean that if you have 2 files: `a.txt` and `b.txt`,
the content of `b.txt` will be put after the content of `a.txt`.

The order of your text matters because the game will start at the first one.

Note that the sub folders names does not count when sorting alphabetically.

To be sure that all of your text files are in the order you want, there are multiple solutions:
- name all your files with a leading number (with leading 0)
- name the first file `0.txt` and use `label` and `jump` tags to go to other files
- just use one file (not recommended)

## Output

For the output file, just choose a file name that does not exist.
If the file exist it will be replaced by whatever the program output.
