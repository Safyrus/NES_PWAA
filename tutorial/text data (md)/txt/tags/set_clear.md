# Flags

Flags are part of the save of the game.
They can be either set or clear by tag.
Flag can be used with a `jump` tag to take action based on some condition.
There are 128 flags, from flag 0 to flag 127.

Note:
Flag 0, 1 and 2 are clear each time when entering a new dialog.
There are used in NES-PWAA for "Hold it!" "Objection! (false)", "Objection! (true)" respectively.


# Set & Clear Tag

The `set` tag set a flag, and the `clear` tag clear a flag.

There each take 1 number as an argument that correspond to the flag to set/clear.

# Clear Tag

This tag clear a flag in memory.

It takes 1 number argument that correspond to the flag to set.

## Example

<const:MACGUFFIN,5>

You pick-up the MacGuffin<set:MACGUFFIN><p> <!-- Set the macGuffin flag -->

<!-- later -->

<jump:have_item,1,0,MACGUFFIN>

<label:no_item>
You do not have what it take.
<!-- ... -->

<label:have_item>
There it is ! The MacGuffin !<p>
<clear:MACGUFFIN> <!-- Clear the macGuffin flag -->
Oh no ! You broke it !<p>
<!-- ... -->

## Tips
