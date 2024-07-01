# Wait tag

This tag wait for a number of frames to pass.

It takes 1 number as an argument.
This number is the number of frame to wait.
So the bigger the value, the longer you wait.

Note: remember that the game is normally at 60 FPS,
and so, a wait of 60 mean that the game will wait for 1 second. 

## Example

Wait i'm thinking...<wait:40><b>
OK I'm done<b>
<wait:10>Wait!<wait:100>Nothing :)<p>

## Tips

This tag is great for timing things, obviously.
But it can also be used to add small pauses between sentences and clauses (like after "," or ".").
This give a feel of a more natural dialog.

If you combine a speed of 0 (with `<speed>`) and add a wait time after each word,
you can display text word y word instead of character by character.
This can give a robotic feeling to the dialog.
