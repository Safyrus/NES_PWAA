# Name tag

The `<name>` tag change the name at the bottom left of the dialog box.
This tag take an argument that specify the new name.
The argument is a number that correspond to the n'th name in the name list (more info after).

It is intended to indicate which character is speaking.

You don't need to add this tag for every dialog box.
The name will only change when a new `<name>` tag is encounter.

## Example

<const:NAME_A,3>
<const:NAME_B,4>

<name:NAME_A>
I am the character A!<p>
<name:NAME_B>
And I am the character B!<p>

## Editing the list

Changing the list is quite cumbersome for now.
To edit the list, you must change 2 things: Name address and Name tiles.

### Name tiles

Name tiles are located in the file "data/FONT.chr".
There are the bottom halves of the first bank
without counting the last tiles representing the cursor and dialog box tiles.

(TODO: show images of what is editable)

You can put any graphic you want as long as it fit into the designed name space.

Note that a name is X tile long and names must fit entirely into these tiles.
Important information: The first name necessary start at the first tile in the name space. Each name follow one after the other.
Also, the order of the names are important too for the next part.

(TODO Show img of incorrect and correct way)

### Name address

When you have your name tiles, you must indicate for each name the tile it starts from.
Thats the role of the name address list.

The name address list can be edited at "asm/dialog/name.asm".
The list start after the line `NAMES_ADR_LO:` (At the top of the file).
Each entry is written as `.byte ` followed by the tile number where the name start.
(You can see it in YYCHR when clicking on tile on the bottom left)

The first entry is always `.byte $80` and the last is always `.byte ` + the size in tiles of the last name
The order of the list is important.
It must be in the same order as the name tiles.
To be technical: Numbers should always increase and not decrease, otherwise the code will not work.

(TODO: show img example list)


## Tips

You can use a name with a value of 0 to hide the name.

It may also be possible to not write a name, but graphic instead.
This can be used to draw symbols or other things where the name should be displayed.
