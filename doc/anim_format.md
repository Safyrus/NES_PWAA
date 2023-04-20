# Animation JSON format

JSON structure

```json
[
  // this is one animation
  {
    "name": "name", // Optionnal. Name of the animation/background
    "idx": 0, // Optionnal. Index to use during dialog scripts
    "background": "img_path", // Required. path to the background
    "character": [ // Required. paths to each animation frames
      "img_path",
      "...",
    ],
    "time": [ // Required. delay between each character frames
        16
        ...,
    ],
    "palettes": [ // Optionnal. color palettes to use
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
