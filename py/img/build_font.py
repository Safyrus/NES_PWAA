import argparse
import math
import numpy as np
import os
from PIL import Image
from glob import glob
from tile import tiles2chr


def get_names(name_folder):
    # get all name images
    name_imgs = glob("*.png", root_dir=name_folder)

    # build names list
    names = {}
    for n in name_imgs:
        # open image
        path = os.path.join(name_folder, n)
        img: Image.Image = Image.open(path)
        # get name size
        size = math.ceil(img.width / 8)

        # too many color warning
        n_col = len(img.getcolors())
        if n_col > 4:
            print(f"\033[33mWARNING: Too many colors in image for name '{n}' (have {n_col}, should be 4 or less)\033[0m")
            # rectify
            img = img.quantize(4)
        # convert image to grayscale
        img = img.convert("L")

        # incorrect size warning
        if img.height != 8 or img.width % 8:
            print(f"\033[33mWARNING: Invalid image size for name '{n}'\033[0m")
            # rectify
            new_img = Image.new(img.mode, (size * 8, 8))
            new_img.paste(img)
            img = new_img

        # add name to list
        names[n] = (size, np.array(img) >> 6)

    return names


def output_names_asm(names, out_asm_path):
    with open(out_asm_path, "w", encoding="utf-8") as f:
        f.write("; This file was generated\n\n")

        for i, (name, data) in enumerate(names.items()):
            const_name = "NAME_" + os.path.splitext(name)[0].upper()
            f.write(f"{const_name} = {i}\n")

        f.write("\nnames_list:\n")
        total_size = 0x80
        for name, data in names.items():
            f.write(f"    .byte ${hex(total_size)[2:].upper()} ; {os.path.splitext(name)[0]}\n")
            total_size += data[0]
        f.write(f"    .byte ${hex(total_size)[2:].upper()} ; END\n")
        if total_size > 0xFF:
            print(f"\033[33mWARNING: Names take too much space ({total_size-0xFF} tile overflow). Remove or make some shorter\033[0m")


def add_font(chr_tiles, name, font_folder):
    # open image
    path = os.path.join(font_folder, name)
    img: Image.Image = Image.open(path)

    # check image size
    if img.width != 128 or img.height != 64:
        print(f"\033[33mWARNING: Invalid image size for font '{name}'\033[0m")
        # rectify
        new_img = Image.new(img.mode, (128, 64))
        new_img.paste(img)
        img = new_img

    # check colors
    n_col = len(img.getcolors())
    if n_col > 4:
        print(f"\033[33mWARNING: Too many colors in image for font '{name}' (have {n_col}, should be 4 or less)\033[0m")
        # rectify
        img = img.quantize(4)
    # convert image to grayscale index
    img = img.convert("L")
    img = np.array(img) >> 6

    return add_imgarray(chr_tiles, img)


def add_names(chr_tiles, names):
    img = Image.new("L", (128 * 8, 8))

    x1 = 0
    x2 = 512
    for _, data in names.items():
        if data[0] * 8 + x1 < 512:
            img.paste(Image.fromarray(data[1]), (x1, 0))
            x1 += data[0] * 8
        else:
            img.paste(Image.fromarray(data[1]), (x2, 0))
            x2 += data[0] * 8

    return add_imgarray(chr_tiles, np.array(img, dtype=np.uint8))


def add_imgarray(chr_tiles, img):
    w = img.shape[1] // 8
    h = img.shape[0] // 8
    # reshape image into tiles
    img_tiles = img.reshape(h, 8, w, 8).swapaxes(1, 2).reshape(h * w, 8, 8)
    # padding
    while len(img_tiles) < 0x80:
        img_tiles = np.append(img_tiles, np.zeros((8, 8), dtype=np.uint8), axis=0)
    # add tiles to chr
    if len(chr_tiles) > 0:
        img_tiles = np.append(chr_tiles, img_tiles, axis=0)

    return img_tiles


def build_font(font_folder, name_folder, out_chr, out_font, out_name):
    # names
    names = get_names(name_folder)
    output_names_asm(names, out_name)

    # get all font images
    font_imgs = glob("*.png", root_dir=font_folder)
    if "ascii.png" not in font_imgs:
        print("\033[31mERROR: ascii.png dos not exist\033[0m")
        exit(1)
    i = font_imgs.index("ascii.png")
    del font_imgs[i]

    tiles = np.array([], dtype=np.uint8)
    # output ascii.png
    tiles = add_font(tiles, "ascii.png", font_folder)
    # output names
    tiles = add_names(tiles, names)
    # for x font
    for font in font_imgs:
        # output font
        tiles = add_font(tiles, font, font_folder)

    chr_data = tiles2chr(tiles)
    with open(out_chr, "wb") as f:
        f.write(chr_data)

    with open(out_font, "w", encoding="utf-8") as f:
        f.write("; This file was generated\n\n")
        f.write(f"FONT_ASCII = 0\n")
        f.write(f"FONT_NAMES = 1\n")
        for i, font in enumerate(font_imgs):
            const_name = "FONT_" + os.path.splitext(font)[0].upper()
            f.write(f"{const_name} = {str(i+2)}\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-if", "--font_folder", default="font")
    parser.add_argument("-in", "--name_folder", default="name")
    parser.add_argument("-oc", "--output_chr_path", default="FONT.chr")
    parser.add_argument("-of", "--output_font_path", default="font.asm")
    parser.add_argument("-on", "--output_name_path", default="name.asm")
    args = parser.parse_args()

    build_font(
        args.font_folder,
        args.name_folder,
        args.output_chr_path,
        args.output_font_path,
        args.output_name_path,
    )
