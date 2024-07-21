# Character Image

## Limitation

Background images must:
- Have a fix size of 256 by 192 pixels.
- Have at most 6 colors + 1 color from background.
- Must have at least 1 frame of animation.

### Sprites

The image is cut into tiles and sprites.

Tiles have the 3 most used colors.
Sprites have the other 3 colors.

This allows to have a lot of different colors close to each others.
But if the image use a lot of sprites, this may indices flickers.

To reduce flickering, try to:
- use your 3 least use colors in patch, avoid alone pixels.
- Have a ratio of most used by least used colors around or above 6 (~15%).

## JSON

Each JSON file is a list of object that represent background/animation.

_Note: Paths are relative to `py/imgEncoder/encode_region.py`_

Object fields:

- **name**: (Required)
  Unique name to identify the animation.
  If 2 animations have the same name,
  there are considered the same,
  even if the actual image file is different.
- **idx**: (Strongly recommended)
  The index of the animation.
  This is a number that refer to the animation and character used by text data.
  For example: if an animation have an index of 4, in your text, you use `<animation:4>` to display it.

  There are 128 characters (0 to 127). Each of have 128 animations (0 to 127).
  The index represent both the character and animation.
  That means if your index is 259, to use it, you use `<character:2><animation:3>`
  because 259/128 = 2 (character) with a remainder of 3 (animation).

  Empty index will be fill with empty image.
  For example, if you only have a background on index 2 and 4, index 0, 1 and 3 will be fill with empty image.
- **background**: (Optional)
  File path to the background image that the animation will be display over.
  This help reduces having blocky border around the animation.
  But that also mean that using this animation over another background may look glitchy.
  PNG files are recommended. Other format may or may not work.
- **character**: (Required)
  This field must be a list of file path that constitute the animation.
  The list must have at least 1 image.
  The order matters, the first image is the first frame of animation.
  PNG files are recommended. Other format may or may not work.
- **time**: (Required)
  This field is a list of number
  that indicates the time between each animation frame.
  Time is express as game frame (FPS). So 60 = 1 second.
  Time value range from 0 (instant) to 255 (~4.2 seconds).
  The size of the list must be the same size as the character list.
- **palettes**: (Optional)
  Indicate what color to use with this animation.
  By default, the project will try to find the best NES color to used.
  Using this field will override the project choice.
  
  The value must be a list of 2 lists.
  The first list must have 4 numbers and indicates what color to use for the background image.
  The second list must have 6 numbers and indicate the character color palette.

  Numbers must be between 0 and 63, and correspond to a NES color.
  (to know what color is what number: https://www.nesdev.org/wiki/PPU_palettes)

  Example:
  ```json
  "palettes": [
    [15, 0, 16, 32], // grayscale background color palette
    [0, 0, 0, 0, 0, 0] // character color palette
  ]                    // background images don't care about the actual values
  ```
- **palettes_each**: (Optional)
  Indicate what color to use for each frame of the animation.
  If used, the `palettes` field is ignored.
  This is a list of palette value (same as the palette field).
  The list size must be the same as the character list size.

  Example:
  ```json
  "palettes_each": [
      [[6, 23, 39, 48], [1, 17, 15, 38, 54, 48]], // frame 1 colors
      [[6, 23, 39, 48], [1, 17, 15, 54, 38, 48]] // invert the 4th and 5th colors for frame 2
  ]
  ```
