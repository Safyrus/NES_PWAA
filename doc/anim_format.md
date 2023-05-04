# Animation JSON format

JSON structure

```json5
[
  // this is one animation
  {
    "name": "name", // Optional. Name of the animation/background
    "idx": 0, // Optional. Index to use during dialog scripts
    "background": "img_path", // Required. path to the background
    "character": [ // Required. paths to each animation frame
      "img_path_1", // Frame 1
      "other_img_path", // Frame 2
      "...",
    ],
    "time": [ // Required. delay between each character frame
        16, // Frame 1
        8, // Frame 2
        ...
    ],
    "palettes": [ // Optional. color palettes to use
        [0, 0, 0, 0], // background color palette
        [0, 0, 0, 0, 0, 0] // character color palette
    ],
    "palettes_each": [ // Optional. color palettes to use for each animation frame. Override "palettes" key.
      // Frame 1
      [
          [0, 0, 0, 0], // background color palette
          [0, 0, 0, 0, 0, 0] // character color palette
      ],
      // Frame 2
      [
        ...
      ],
      ...
    ]
  },
  // other animations
  {
    ...
  },
  ...
]
```
