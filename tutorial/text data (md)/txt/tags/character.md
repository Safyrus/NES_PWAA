# Character Tag

Change the current character to be displayed.
The character will remain the same until another `character` tag is encounter.

This tag take 1 number argument.
The number correspond to the index of the character to use.

For more information on character index, see the image part of the tutorial.

If a value of 0 is used and a previous `animation` tag was used with also a 0 value,
then the character will not be displayed.

## Example

<const:CHR_A_NEUTRAL,22>
<const:CHR_A_HAPPY,23>
<const:CHR_NONE,0>

<character:CHR_A_NEUTRAL>
You tell A a joke.

<character:CHR_A_HAPPY>
It seems happy about it.

<character:CHR_NONE>
And then it leaves happy.

## Tips

A lot of poses can give a character more life, but it also takes cartridge space.
So, try to change only what's important and keeping the rest the same.
For example: change only the head but keep the body the same.
