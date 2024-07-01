# Color tag

This tag change the text color.
The color will remain the same until another `color` tag is encounter.

The argument is the color to use. It can only take one of these value:
- 0: white (default)
- 1: red
- 2: blue
- 3: green

## Example

Colors!<wait:8>We have<b>
<color:1>RED<color:0>,
<color:2>BLUE<color:0>,
and <color:3>GREEN<color:0>
!<p>

## Tips

Use colors to emphasize important word or way of speaking
(For example: Ace Attorney use blue text when a character is thinking).

## Note

For now, it is impossible to change colors without editing the code.
(mainly located and hard-coded in "asm/vector/scanline_pal_change.asm")
The reason is that it involve complex palette change mid-frame (which is very technical on the NES).
I may refactor that a little in the future to allow changing those number easily. 
