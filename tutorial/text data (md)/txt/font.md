# Font

All fonts of the game are located in "data/FONT.chr".
To edit them, use YYCHR or another software than can do the same thing.

## Char set

All font use the same character sets.

There are 128 unique characters.
The first 32 are control characters.
The 96 others are printable characters.

## Alignment and Index

1 Bank (256 tiles or 4 KB) store 2 fonts.
The first on the upper half (128 first tiles) and the second on the bottom half (128 last tiles).

When using the `font` tag, you must specify the index of the font.
This index is the bank number times 2, plus 1 if the font is store in the bottom half.

For example, if the FONT.chr is the default one,
font 0 is ASCII,
font 2 is Japanese hiragana
and font 3 is Japanese katakana.

## Font 1

Font 1 is special and does not represent a font.
It is used to store tiles for the dialog box, different names and the cursor.

If you use it, it will draw these graphics.

## Adding more font

You can add more font by adding banks to the FONT.chr file.
You can have a maximum of 128 font (from 0 to 127).

Note that if your using YYCHR, it cannot increase the file size.

For that, you can either:
- use another software
- use one of the python script found in "py/chr"
- google it

## Notes

Because control character will not be print,
you can draw anything you want here.

