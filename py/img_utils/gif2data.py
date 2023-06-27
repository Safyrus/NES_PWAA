import argparse
import glob
import json
import os
import numpy as np
import shutil
from PIL import Image
from sklearn.cluster import KMeans
from tqdm import tqdm

from nes_pal import closest_nes_color
from gif_name_idx import GIF_NAME_IDX


def get_gif_time(gif, FPS=60) -> list[int]:
    time = []
    for i in range(gif.n_frames):
        try:
            gif.seek(i) # set gif to frame i
            duration = gif.info["duration"]
            duration = round(duration/(1000/FPS)) # millisecond -> frame count
            time.append(duration)
        # because some gif are not well encoded
        except Exception as e:
            print(e)
            print("error with frame", i)
    return time


def find_palette(img : Image, k=7, nb_try=25) -> list[int]:
    #
    img = img.convert("RGB")
    # 1D image
    vec = np.array(img).reshape(-1, 3)
    #
    model = KMeans(n_clusters=k, n_init=nb_try).fit(vec)
    # casr palette to tuple
    palette = tuple([round(x) for x in model.cluster_centers_.flatten()])

    return palette

def add_img_2_bnk(img, img_dir, imgs_bank, palette):
    img_dir = os.path.split(img_dir)[0]
    # compare to bank
    array = np.array(img.convert("RGB"))
    for k,(v,_) in imgs_bank.items():
        # if the 2 images are in the same folder
        if img_dir == os.path.split(k)[0]:
            # if the 2 images are the same
            dif = np.sum(array != np.array(v))
            # print(dif)
            if dif == 0:
                # return the name of the image in the bank
                return k, imgs_bank
    # get image name
    name = os.path.join(img_dir, str(len(imgs_bank)) + ".png")
    # save the new image to the bank
    imgs_bank[name] = (img.convert("RGB"), palette)
    return name, imgs_bank


def pal2nes(pal, img):
    # quantize the image
    pal_image= Image.new("P", (1,1))
    pal_image.putpalette(pal + (0,0,0)*(256-len(pal)//3))
    quantize_img = img.convert("RGB").quantize(palette=pal_image, dither=Image.Dither.NONE)
    # get sorted color count
    colors = sorted(quantize_img.getcolors(), key= lambda x: x[0])
    colors.reverse()
    colors = np.pad(colors, 8)
    # RGB -> NES
    nes_pal = []
    for c in colors[1:7]:
        nes_pal.append(closest_nes_color(pal[c[1]*3:c[1]*3+3]))
    nes_pal = [[0, 15, 16, 32], nes_pal]
    return nes_pal


def main(args):
    # find all gif
    files = glob.glob(args.folder + '/**/*.gif', recursive=True)
    files = sorted(files)
    print("number of gif found:",len(files))

    # index counter
    idx = 1000 # let space for custom index
    #
    img_bank = {}
    animations = []

    # for each gif
    last_folder = ""
    for file in tqdm(files, desc=f"create animations"):
        # animation name
        ani_name = os.path.split(file)[1].split(".")[-2].upper()
        anim_idx = idx if ani_name not in GIF_NAME_IDX else GIF_NAME_IDX[ani_name]
        # setup the animation data
        animation = {
            "name": ani_name,
            "idx": anim_idx,
            "background": "../../data/empty.png",
            "character": [],
            "time": [],
            "palettes_each": [],
        }
        # increment index counter
        idx += 1
        # open gif
        gif = Image.open(file)
        # set animation timing
        animation["time"] = get_gif_time(gif)
        # find file folder
        folder = os.path.relpath(file, args.folder)
        folder = os.path.join(args.out, folder)
        folder = os.path.split(folder)[0]
        # if folder not the same as the last one
        if last_folder != folder:
            last_folder = folder
            # get palette
            # (we suppose that every gif in a folder has the same palette.
            # This lead to more coherent images)
            # TODO : use avarage palette (should fix using a wrong palette from the first example)
            pal = find_palette(gif)
        palettes = []

        # for each frame
        for i in range(gif.n_frames):
            try:
                # set gif to frame i
                gif.seek(i)
                #
                gif.apply_transparency()
                # get images name
                path = os.path.relpath(file, args.folder)
                path = os.path.join(args.out, path)
                img_name, img_bank = add_img_2_bnk(gif, path, img_bank, pal)
                animation["character"].append(img_name.replace("\\", "/"))
                #
                palettes.append(pal2nes(pal, gif))
            # because some gif are not well encoded
            except Exception as e:
                print(e)
                print("error with file:", file)

        # set animation palettes
        animation["palettes_each"] = palettes
        # add animation
        animations.append(animation)

    # remove old images
    if os.path.exists(args.out):
        print("remove old images")
        shutil.rmtree(args.out)
    # save image bank
    for k,(v,p) in tqdm(img_bank.items(), desc="save images"):
        # quantize the image
        pal_image= Image.new("P", (1,1))
        pal_image.putpalette(p + (0,0,0)*(256-len(p)//3))
        quantize_img = v.quantize(palette=pal_image, dither=Image.Dither.NONE).convert("RGB")
        # save image
        # path = os.path.relpath(k, args.folder)
        # path = os.path.join(args.out, path)
        dir = os.path.split(k)[0]
        os.makedirs(dir, exist_ok=True)
        quantize_img.save(k)
    
    # save animation
    print("save animations")
    anim_files = {}
    for a in animations:
        if len(a["name"].split("-")) >= 2:
            a_name = ""
            for s in a["name"].split("-", )[:-1]:
                a_name += s
        else:
            a_name = "ANIM"
        if a_name not in anim_files:
            anim_files[a_name] = []
        anim_files[a_name].append(a)
    os.makedirs(args.json, exist_ok=True)
    for k,v in anim_files.items():
        with open(os.path.join(args.json, k + ".json"), "w") as f:
            json.dump(v, f, indent=2)


if __name__ =="__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("folder", type=str)
    parser.add_argument("--json", default="anim", type=str)
    parser.add_argument("--out", default="out", type=str)
    args = parser.parse_args()
    main(args)
