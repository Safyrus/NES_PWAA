import argparse
import json
import os
import numpy as np
from tqdm import tqdm

from img_2_tiles import img_2_tile, tile_2_chr
from img_col_reduce import bkg_col_reduce
from encode_frame import img_2_idx
from rle_inc import rleinc_encode


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", dest="input", type=str, required=True)
    parser.add_argument("-o", "--output", dest="output", type=str, required=False, default="out.bin")
    parser.add_argument("-c", "--chrrom", dest="chr", type=str, required=False, default="out.chr")
    parser.add_argument("-b", "--bank", dest="bnk", type=int, required=False, default=0)
    return parser.parse_args()


def main():
    args = get_args()
    chr = []
    encoded_images = []

    print("read json")
    with open(args.input, "r") as f:
        evidences = json.load(f)

    print("check if all images exist")
    error = False
    for e in evidences:
        if not os.path.exists(e["image"]):
            print("ERROR: file", e["image"], "does not exist")
            error = True
    if error:
        exit(1)

    for evidence in tqdm(evidences, desc="encode images"):
        # image to tiles
        img, _ = bkg_col_reduce(evidence["image"])
        img = img_2_idx(img)
        tiles, indices = img_2_tile(img)

        for i, tile in enumerate(tiles):
            # find matching tile
            found = False
            for j, t in enumerate(chr):
                if np.array_equal(tile, t):
                    indices[i] = j
                    found = True
            # add the tile to CHR if it aws not found
            if not found:
                indices[i] = len(chr)
                chr.append(tile)

        # RLEINC
        indices = np.array(indices)
        rle_lo = rleinc_encode(indices % 256)
        rle_hi = rleinc_encode((indices // 256) + args.bnk + 0xC0)
        rle = rle_lo + rle_hi

        # encoded image = RLEINC + palette
        encoded_images.append({"data": rle, "pal": evidence["palette"], "idx": int(evidence["idx"])})

    print("sort data")
    for i, e1 in enumerate(encoded_images):
        min = e1["idx"]
        idx = i
        for j in range(i, len(encoded_images)):
            e2 = encoded_images[j]
            if e2["idx"] < min:
                min = e2["idx"]
                idx = j
        encoded_images[i], encoded_images[idx] = encoded_images[idx], encoded_images[i]

    print("convert image to binary")
    encoded_data = []
    for image in encoded_images:
        encoded_data.append(len(image["data"])+4) # size
        encoded_data.extend(image["pal"])         # palette
        encoded_data.extend(image["data"])        # data
    encoded_data = bytes(encoded_data)

    print("convert chr to binary")
    CHR_rom = []
    for t in chr:
        CHR_rom.extend(tile_2_chr(t))
    CHR_rom.extend(np.zeros(4096 - (len(CHR_rom) % 4096), dtype=int))
    CHR_rom = bytes(CHR_rom)

    print("write data")
    with open(args.chr, "wb") as f:
        f.write(CHR_rom)
    with open(args.output, "wb") as f:
        f.write(encoded_data)

    print("done")


if __name__ == "__main__":
    main()
