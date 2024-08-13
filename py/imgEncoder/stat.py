import argparse
import json
import os
import numpy as np
from tqdm import tqdm

from img_2_tiles import img_2_tile
from img_col_reduce import bkg_col_reduce
from encode_frame import img_2_idx
from img_col_reduce import char_col_reduce
from encode_frame import find_palettes

def check_file(data):
    print("check files")
    error = False
    for anim in data:
        if not os.path.exists(anim["background"]):
            print("ERROR (stat): file", anim["background"], "does not exist")
            error = True
        for c in anim["character"]:
            if not os.path.exists(c):
                print("ERROR (stat): file", c, "does not exist")
                error = True
    return error


def count_bkg_tiles(data, alltiles = {}, background_images={}):
    for anim in tqdm(data, desc="count background tiles"):
        if anim["background"] not in background_images:
            background_images[anim["background"]] = {}
            # image to tiles
            img, _ = bkg_col_reduce(anim["background"])
            img = img_2_idx(img)
            tiles, _ = img_2_tile(img)
            #
            for t in tiles:
                k = str(t)
                if k in alltiles:
                    alltiles[k] += 1
                else:
                    alltiles[k] = 1
                if k in background_images[anim["background"]]:
                    background_images[anim["background"]][k] += 1
                else:
                    background_images[anim["background"]][k] = 1
    return alltiles, background_images


def count_chr_tiles(data, alltiles = {}, character_images={}):
    for anim in tqdm(data, desc="count character tiles"):
        chars = anim["character"]
        if not chars: continue
        for i in range(len(chars)):
            if chars[i] in character_images: continue
            character_images[chars[i]] = {}

            img, _ = char_col_reduce(chars[i])
            img = img_2_idx(img)
            palettes, _ = find_palettes(img)
            for j in range(1, 4):
                img = np.where(img == palettes[3][j], 0, img)
            tiles, _ = img_2_tile(img)
            #
            for t in tiles:
                k = str(t)
                if k in alltiles:
                    alltiles[k] += 1
                else:
                    alltiles[k] = 1
                if k in character_images[chars[i]]:
                    character_images[chars[i]][k] += 1
                else:
                    character_images[chars[i]][k] = 1
    return alltiles, character_images


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", type=str, dest="input", nargs="+", required=True)
    parser.add_argument("-n", type=int, default=10)
    args = parser.parse_args()

    tiles = {}
    bkg_images = {}
    chr_images = {}
    for filename in args.input:
        print("open", filename)
        with open(filename, "r") as f:
            data = json.load(f)

        error = check_file(data)
        if error: exit(error)
        
        tiles, bkg_images = count_bkg_tiles(data, tiles, bkg_images)
        tiles, chr_images = count_chr_tiles(data, tiles, chr_images)

    tiles = sorted(tiles.items(), key=lambda item: item[1], reverse=True)
    total = 0
    unique = {}
    with open("tiles.csv", "w") as f:
        for t in tiles:
            total += t[1]
            if t[1] in unique:
                unique[t[1]] += 1
            else:
                unique[t[1]] = 1
            print(t[1], file=f)

    with open("image_tiles_count.csv", "w") as f:
        for k,v in bkg_images.items():
            print(k, len(v.keys()), file=f)
        for k,v in chr_images.items():
            print(k, len(v.keys()), file=f)

    with open("tiles.json", "w") as f:
        json.dump(tiles, f)

    print("number of tiles:", len(tiles))
    print(f"{args.n} most used tiles count:")
    s = 0
    for t in tiles[:args.n]:
        if args.n <= 50:
            print(t[1])
        s += t[1]
    print(f"{args.n} most used tiles represent {s} out of {total} ({(s*100)//total}%)")
    print("number of time used : number of tile", unique)

if __name__ == "__main__":
    main()
