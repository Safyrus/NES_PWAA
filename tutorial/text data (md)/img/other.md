# Other info

## Fade in/out

This is just an idea, but it may be possible to do a tricky effect
using animation, background and palettes to fade in/out a character.

## Electric shock effect

You can easily do an electric shock effect
by changing only the palette during the animation.
This avoids consuming space for image that are basically the same.

## Having small images

To gain space, try to reuse the same 8*8 pixels tiles in your images.

An animation with multiple frames will save as images the first frame and the difference in tiles between each frame.

That means that an animation translating the previous frame by x pixels
will result in a complete new image, decreasing available storage space.

So, try to have animations that only change part of the image.
Like a character talking animations where only the head change and the body remain the same.
