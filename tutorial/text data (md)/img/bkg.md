# Background Image

## Limitation

Background images must:
- Have a fix size of 256 by 192 pixels.
- Have at most 4 colors.

## JSON

Each JSON file is a list of object that represent background/animation.

_Note: Paths are relative to `py/imgEncoder/encode_region.py`_

Object fields:

- **name**: (Required)
  Unique name to identify the background.
  If 2 backgrounds have the same name,
  there are considered the same,
  even if the actual image file is different.
- **idx**: (Strongly recommended)
  The index of the background.
  This is a number that refer to the background used by text data.
  Index must be unique and be between 0 and 127 (included).

  For example: if a background have an index of 4, in your text, you use `<background:4>` to display it.

  If the field is not used, the project will assign a valid index.
  But you should not rely on that.
- **background**: (Required)
  File path to the actual image.
  PNG files are recommended. Other format may or may not work.
- **character**: (Optional ?)
  This field, if used, must be an empty list `[]`.
  Otherwise, the image is considered an animation and not a background.
- **time**:
  Not used, must be an empty list `[]` if used.
- **palettes**: (Optional)
  Indicate what color to use with this background.
  By default, the project will try to find the best NES color to used.
  Using this field will override the project choice.
  
  The value must be a list of 2 lists.
  The first list must have 4 numbers and indicates what color to use.
  The second list must have 6 numbers and indicate character color palette
  (for background image, this list is not used)
  Numbers must be between 0 and 63, and correspond to a NES color.
  (to know what color is what number: https://www.nesdev.org/wiki/PPU_palettes)

  Example:
    ```json
    [15, 0, 16, 32], // grayscale background color palette
    [0, 0, 0, 0, 0, 0] // character color palette
                       // background images don't care about the actual values
    ```
- **palettes_each**:
  Not used, must be an empty list `[]` if used.
