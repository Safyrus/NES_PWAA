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
      "img_path",
      "...",
    ],
    "time": [ // Required. delay between each character frame
        16,
        ...
    ],
    "palettes": [ // Optional. color palettes to use
        [0, 0, 0, 0], // background color palette
        [0, 0, 0, 0, 0, 0] // character color palette
    ]
  },
  // other animations
  {
    ...
  },
  ...
]
```
