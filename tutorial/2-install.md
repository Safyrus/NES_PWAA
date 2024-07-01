# Installing the project

## Install the prerequisite

You can find them in the [README](../README.md).

/!\ If you don't have them, the project will not work /!\

## Tools for developing

You don't need them, but they are recommended for making your game without taking years.

### Text editor

If you have a pc, you should have one.
But I **recommend strongly** to use something else than the default windows notepad.

I prefer [VS-Code](https://code.visualstudio.com/), but you can use 
[Notepad++](https://notepad-plus-plus.org/),
[Sublime Text](https://www.sublimetext.com/),
[Obsidian](https://obsidian.md/) or any other.
Just choose one that you like.

### Image / Pixel art editor

Any image editor will do.
But still, this is a small list of possible software to use:

- [Aseprite](https://www.aseprite.org/): Personal recommendation. Not free but affordable, and have many features related to pixel art.
- [Photoshop](https://www.adobe.com/products/photoshop.html): Not cheap and overkill for this, but you may already have it so why not using it.
- [Lospec Pixel Editor](https://lospec.com/pixel-editor/): an online pixel art editor. Free, simple and made for pixel art.
- [Gimp]: Free and open source general image editor.
- [Paint.net](https://www.getpaint.net/): More features than MSPaint.
- [MSPaint](https://archive.org/details/MSPaintWinXP): very, very basics and default on Windows.
- Others that I don't know about.

### Musics and audio SFX

If you want to make music for your game, you will need to install and make your musics on [FamiStudio](https://famistudio.org/).
It is the only audio format that the NES-VN engine recognize.
Don't worry, if you have work with a DAW like FLStudio, you will not be destabilized.
Besides, this is a very cool software to do real NES musics!

You can also make your music on [FamiTracker](https://famitracker.com/) and import them on FamiStudio, but this might not work 100%.

(current FamiStudio NES engine version used in this project is 4.0.0 (TODO: update FamiStudio))

### YYCHR

[YYCHR](https://w.atwiki.jp/yychr/) is a software to open and edit NES graphics.
Needed for editing .CHR files (like the font file).

## Others

### Config file

For now, you don't need to worry about it unless you need to specify the installation path of a prerequisite. In that case, just edit the corresponding line.

### Make file

You also don't need to worry about this file.
But you should know how to run commands with it.
They are details [here](../README.md#commands).

## Verifying

To verify if everything is installed and set up correctly, try to build the game by running `make -s resource` and then `make -s`.
If everything is fine, then run it to continue the tutorial.
If errors occurred, you may have done something incorrectly, or there is something else wrong.

### Troubleshooting

*TODO: Common issues*

If nothing has resolved your problem...
try to google it,
or create an issue on the GitHub (if no other talk about your problem). I (or someone else) may see it one day and answer it (but no promise)
