# Photo Image

## Limitation

Background images must:
- Have a fix size of 64 by 64 pixels.
- Have at most 4 colors.
- Photo must be display when the dialog box is.
- Photo share the same color palette as the text.

## JSON

The JSON file is a list of object that represent photo.

_Note: Paths are relative to `py/imgEncoder/encode_region.py`_

fields:

- **image**: (Required)
  Path to the actual image.
- **idx**: (Strongly recommended)
  The index of the photo.
  This is a number that refer to the photo used by text data.
  For example: if a photo have an index of 4, in your text, you use `<photo:4>` to display it.
  Photo index range from 0 to 127 (included).
  If the field is not used, the project will assign a valid index.
  But you should not rely on that.

Example of a JSON file:

```json
[
    {
        "image": "../../data/burger.png",
        "idx": 0
    },
    {
        "image": "../../data/lamp.png",
        "idx": 1
    }
]
```
