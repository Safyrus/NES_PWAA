# Animation tag

Change the current animation to be displayed.
The animation will remain the same until another `animation` tag is encounter.

This tag take 1 number argument.
The number correspond to the index of the animation to use.

For more information on animation index, see the image part of the tutorial.

If a value of 0 is used and a previous `character` tag was used with also a 0 value,
then the character (and so the animation) will not be displayed.

## Example

<character:CHR_A_NEUTRAL>
<const:ANI_A_TALK>
Ho, hello you!
<const:ANI_A_STAND><p>

## Tips
