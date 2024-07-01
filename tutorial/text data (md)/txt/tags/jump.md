# Jump tag

This tag jumps to another part of the script, progressing from there.

It takes multiples arguments:
1. address: Required. The address to jump to. Must be a label.
2. 'jump': Optional. Use '1' If you want a `jump` or '0' if you using `act`.
   Default is '1'.
   Technical stuff: This argument is a boolean value to know if a JMP char is added before the jump address.
3. 'next' flag: Optional. 1 = jump if flag is set, 0 = jump anyway.
   Default is '0'.
4. 'condition' flag: Optional if arg 3 not set. The number correspond to the index of the flag to use (see `set` & `clear` tags).
   Default is '0'.

Note that if you want to use argument 4, you will need to add argument 1, 2 and 3 as well.

In most cases, you just want the address to jump to.

## Example 1

<label:loop>
You're in a loop
<jump:loop>

## Example 2


<const:MACGUFFIN,5>

You pick-up the MacGuffin<set:MACGUFFIN><p>

<!-- later -->

<jump:have_item,1,0,MACGUFFIN> <!-- jump to label have_item IF the MacGuffin flag is set>

<label:no_item>
You do not have what it take.
<!-- ... -->

<label:have_item>
There it is ! The MacGuffin !<p>
<clear:MACGUFFIN>
Oh no ! You broke it !<p>
<!-- ... -->

## Tips

Make sure to have your arguments correctly sets.
