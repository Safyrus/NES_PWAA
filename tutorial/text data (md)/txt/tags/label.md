# Label tag

The `label` tag can be used to declare a label.
A label represents the address of its location (the number of character from the start of the script to here).
It is generally used with a `jump` tag to go to a label.

This tag take 1 argument that is the name of the label.
The name will now reference that specific label.
You cannot have multiple labels with the same name.

## Example

<!-- Declare a label to use for later -->
<label:loop_day>

<!-- much later -->
This is the end of the day... again<p>
<jump:loop_day>

## Tips
