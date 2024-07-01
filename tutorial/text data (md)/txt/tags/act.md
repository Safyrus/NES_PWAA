# Act tag

The `act` tag is a complex one, because it uses other tags as well to work.
It can be used to present multiple actions to the player.

When used, the way text is read is slightly different:
1. The dialog box is cleared.
2. The text speed become instantaneous.
3. Each line will be interpreted as a choice.
4. After the last choice, the player must choose a choice.
5. After the player has selected a choice, the script will jump at the address linked with the choice.
6. The script return to a normal state and all `act` effects end.

Each choice is composed of:
1. a `jump` tag with at least 2 argument (the label and the 'jump' argument set to '0').
   The 'next' argument must be set to '1' for all choices unless for the last one where it must be '0'.
   If the 'condition' argument is set, the choice will not be selectable if the corresponding flag is cleared.
2. The text (with no tags) to represent the choice.
3. A `b` tag to mark the end of the choice.

## Example

Make a choice<p>

<act>
<!-- all jump tags here must have the second argument set to '0' -->
<jump:choice_1,0,1>Choice 1<b> <!-- a choice (that is not the last) with the text "Choice 1" that jump to label choice_1-->
<jump:secret,0,1,42>Secret Choice<b> <!-- the flag 42 must be set to select this choice -->
<jump:choice_2,0,0>Choice 2<b> <!-- the 'next' argument is '0', meaning it is the last choice -->

<label:choice_1><fp>You choose choice 1<p><jump:choice_end>

<label:choice_2><fp>You choose choice 2<p><jump:choice_end>

<label:secret><fp>You found the secret choose !<p><jump:choice_end>

<label:choice_end>

## Tips

Note that the dialog box is not cleared after a choice his made.
This can be done by using `fp` directly after the jump.
