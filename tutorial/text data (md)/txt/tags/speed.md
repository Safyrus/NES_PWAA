# Speed tag

This tag change how fast the text is displaying.
The text will remain at this speed until another `speed` tag is encounter.

It takes 1 number as an argument.
This number is the number of frame to wait between each character displayed.
So the smaller the value, the faster the text.

Note: remember that the game is normally at 60 FPS,
and so, a speed of 60 mean that 1 second pass between each character displayed. 

## Example

<speed:8>Slow text<b>
<speed:4>Normal text<b>
<speed:2>Fast text<b>

## Tips

Don't hesitate to use this tag to pass your dialog.
You can also use a slow/fast speed to represent a character way of speech.

If it is fix (I don't remember), you can use a speed of 0 to have instant dialog.
