# Info about Images

Note: as for now, the process of using images is quite complicated and cumbersome.
I may change it in the future to be easier to use.

## Type

The game can display 3 type of images:

- **Background** images: basically a PNG of 256*192px with 4 colors.
- **Animation** images: basically a GIF of 256*192px with 6 colors + 1 of the background color.
- **Photo** images: basically an PNG of 64*64px with the color of the dialog box text.

Their can only be 1 of each type of images on the screen at the same time.

## Order

Each image have always the same order of display:

The animation is drawn on top of the background,
The dialog box is on top of the animation,
and the photo on top of the dialog box

## Data location

The game store images as 2 part.
The CHR part store the actual pixel tiles of the image
The PRG part store info about the image (palette, type, order of tiles, etc.)

Because the game cannot access all the CHR (graphical) data at the same time,
tiles data is separated into 4 CHR regions (1 to 4).
Regions 2, 3 and 4 have a size of 256 KB.
Region 1 also have a size of 256 KB but share space with fonts, UI, and photo.

Any background and animation can be store in any region.
Photos are located in region 1.

It is up to you to choose a region for each of your image.

## PRG Size limitation

All images data in PRG are separated into 3 space,
one for each type of image.
You can choose their size by editing the link.cfg (BNK_EVI, BNK_ANI, BNK_IMG).
Info about how to [edit the link file](../struct/link.md) is in the project structure part of the tutorial.

### CHR limitation

The project will convert your images into tiles and put them into these CHR regions.
If you have a lot of unique images, tiles may go beyond the 256 KB limitation.
The project will try to replace tiles with similar tiles to compress them.
This result in always having tiles size below 256 KB but increase PRG size and lower the image quality.

## JSON

To indicate to the game where all of these images are,
you need to use JSON files.

1 JSON file containing all the photos.
You can config the path in the project config file (`EVIDENCE` value)

4 text files, one for each region, containing a list of JSON files to use (1 file per line).
Note that paths are relative to `py/merge_json.py`.
These text files location can be edited in the config file of the project (`ANIM_LIST_x` value).

Information of how to edit these files are cover in each image type section of the tutorial.

## Good practices

- Have folder that separate backgrounds from animations from photos.
- Have sorted folder containing your real images, especially for animations.
- Separate your animation into multiple JSON files by something logical like character or poses.
- Try to fill all region, you gain nothing by having an empty region, and you may lose image quality.
