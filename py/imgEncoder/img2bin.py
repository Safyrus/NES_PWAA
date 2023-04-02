import argparse
import json
import os
import numpy as np
from img_col_reduce import bkg_col_reduce, char_col_reduce
from encode_frame import img_2_idx, find_palettes, merge_image, apply_palette
from img_2_tiles import img_2_tile
from PIL import Image

EMPTY_IMG = "../../data/empty.png"


def add_unique(value, list):
    if value not in list:
        list.append(value)
    return list


def img2bin(args):
    # variables
    error = False
    img_names = []  # list of pair (path, is_background)
    pal_maps = []

    # open json file
    print("open json")
    with open(args.json) as f:
        json_data = json.load(f)

    # get all file and check if there all exist
    print("check files")
    for anim in json_data:
        # if background image does not exist
        if not os.path.exists(anim["background"]):
            print("ERROR: file", anim["background"], "does not exist")
            error = True
        # add it to the list
        img_names = add_unique((anim["background"], None), img_names)
        for c in anim["character"]:
            # if character image does not exist
            if not os.path.exists(c):
                print("ERROR: file", c, "does not exist")
                error = True
            # add it to the list
            img_names = add_unique((c, anim["background"]), img_names)

    # if a file does not exist then stop here
    if error:
        exit(1)

    if not os.path.exists(args.out):
        print("make dir")
        os.mkdir(args.out)

    # convert all images to tiles
    for i, img_name in enumerate(img_names):
        filename = args.out + str(i) + ".bin"
        img_path, background_path = img_name[0], img_name[1]
        print(f"\033[A\033[2K\rConvert '{img_path}' as '{filename}'")
        # if the image is a character, keep only the 3 most used colors
        if background_path:
            # read and convert image to index
            chr, pal = char_col_reduce(img_path)
            chr = img_2_idx(chr)
            # read and convert background image to index
            bkg, _ = bkg_col_reduce(background_path)
            bkg = img_2_idx(bkg)
            #
            palettes = find_palettes(chr)
            # merge background and character into 1 image
            chr = merge_image(bkg, chr)
            # remove sprite colors from background
            for i in range(1, 4):
                chr = np.where(chr == palettes[3][i], 0, chr)
            # convert image to tiles
            tile_set, _ = img_2_tile(chr)
            tile_set, pal_map = apply_palette(tile_set, palettes)
            pal_maps.append(pal_map)
        else:
            # read and convert image to index
            img, _ = bkg_col_reduce(img_path)
            img = img_2_idx(img)
            # convert image to tiles
            tile_set, _ = img_2_tile(img)
            pal_maps.append(None)
        # save image
        with open(filename, "wb") as f:
            for t in tile_set:
                for b in t:
                    f.write(bytes(b))
    print(f"\033[A\033[2K\rConverted all files")

    return img_names, pal_maps


if __name__ == "__main__":
    # argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-j", "--json", dest="json", type=str, required=False, default="anim.json")
    parser.add_argument("-o", "--output", dest="out", type=str, required=False, default="out/")
    args = parser.parse_args()

    img2bin(args)
