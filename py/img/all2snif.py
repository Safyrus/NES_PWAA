import argparse
import os
import re
import numpy as np
from glob import glob
from tqdm import tqdm
from img2snif import img2snif
from compact import compact, CantFit
from PIL import Image
from const import *
from natsort import natsorted

DEFAULT_TIME = 30
NB_REGION = 4
ANIM_AFTERIDX_REGEX = r"(t[0-9]+)\.png"
ANIM_AFTERNAME_REGEX = r"_(i[0-9]+)(t[0-9]+)?\.png"
ANIM_REGEX = r"(.*)_(i[0-9]+)(t[0-9]+)?\.png"
NO_DIRNAME = True

MAX_PHOTO_WIDTH = 128
MAX_PHOTO_HEIGHT = 128


def path2name(path, anim_idx=False):
    name = os.path.normcase(path)
    name = os.path.normpath(path)
    if NO_DIRNAME:
        name = os.path.basename(path)
    if anim_idx:
        name = re.sub(ANIM_AFTERIDX_REGEX, "", name)
    else:
        name = re.sub(ANIM_AFTERNAME_REGEX, "", name)
    name = os.path.splitext(name)[0]
    name = re.sub(r"[^a-zA-Z0-9]+", "_", name)
    return name.upper()


def mask_per_tile(a, b):
    # get mask of equal pixels
    same_mask = np.all(a == b, axis=-1)
    # get mask of pixels not equal to 0
    zero_mask = np.any(a != 0, axis=-1)
    # get width and height in tile size
    h, w = same_mask.shape
    w = (w // 8) + (w % 8 != 0)
    h = (h // 8) + (h % 8 != 0)
    # reshape into tiles
    same_mask = same_mask.reshape(h, 8, w, 8).swapaxes(1, 2).reshape(h * w, 8, 8)
    zero_mask = zero_mask.reshape(h, 8, w, 8).swapaxes(1, 2).reshape(h * w, 8, 8)
    # compute equality at each tile
    same_mask = np.all(same_mask, axis=(-2, -1))
    zero_mask = np.any(zero_mask, axis=(-2, -1))
    #
    nochange_mask = np.logical_and(same_mask, zero_mask)
    # reshape tiles into pixels
    same_mask_px = np.repeat(same_mask, 8).reshape(w, 8 * h)
    same_mask_px = np.repeat(same_mask_px, 8, axis=0)

    return same_mask_px, nochange_mask


################################
# Argmuents
################################
parser = argparse.ArgumentParser()
parser.add_argument("-if", "--input_folder", dest="folder", required=True)
parser.add_argument("-sf", "--snif_folder", default="snif")
args = parser.parse_args()


################################
# Find Files
################################

# Find files by region
all_files = []
for r in range(NB_REGION):
    files = glob(os.path.join(f"r{r}", "**/*.png"), root_dir=args.folder, recursive=True)
    all_files.append(files)
# add files with no region to region 0
other_files = glob("**/*.png", root_dir=args.folder, recursive=True)
for file in other_files:
    already_in = np.any([file in all_files[r] for r in range(NB_REGION)])
    if not already_in:
        all_files[0].append(file)

# sort files
for r in range(NB_REGION):
    all_files[r] = natsorted(all_files[r])

print(f"Found {sum([len(all_files[r]) for r in range(NB_REGION)])} images")


################################
# Find Animations
################################

anims = []
# for each region
i = 0
for r in range(NB_REGION):
    anims.append({})
    # for each file
    fi = 0
    while fi < len(all_files[r]):
        file = all_files[r][fi]
        i += 1
        # if end with underscore and numbers
        m = re.match(ANIM_REGEX, file)
        if not m:
            fi += 1
            continue
        # get numbers from filename
        grp = m.groups()
        idx = int(grp[1][1:])
        time = int(grp[2][1:]) if grp[2] else DEFAULT_TIME
        # add the animation to the animation list
        name = path2name(file)
        if name not in anims[r]:
            anims[r][name] = {}
        # add image to the animation
        anims[r][name][idx] = (file, time)
        fi += 1

# sort animations indexs
for r in range(NB_REGION):
    for name in anims[r].keys():
        anims[r][name] = dict(sorted(anims[r][name].items()))

print(f"Found {sum([len(x) for x in anims])} anims")


################################
# Find Photos
################################

photos = []
for r in range(NB_REGION):
    photo_reg = []
    for i in range(len(all_files[r])):
        img_path = os.path.join(args.folder, all_files[r][i])
        img: Image.Image = Image.open(img_path)
        w, h = img.size
        if w <= MAX_PHOTO_WIDTH and h <= MAX_PHOTO_HEIGHT:
            photo_reg.append(all_files[r][i])
    photos.append(photo_reg)

print(f"Found {sum([len(x) for x in photos])} photos")


################################
# Convertion
################################

snif_files = []
# Convert each file
for r in range(NB_REGION):
    snif_files.append([])
    bar = tqdm(all_files[r], desc=f"Converting region {r}...", dynamic_ncols=True)
    for file in bar:
        bar.set_description(f"Convert region {r} ({os.path.basename(file)})")
        # get output file path
        out = os.path.splitext(file)[0] + ".snif"
        out = os.path.join(args.snif_folder, out)
        img_path = os.path.join(args.folder, file)
        # add to list for next step
        snif_files[r].append(out)
        # if animation
        name = path2name(file)
        is_anim = name in anims[r]
        is_photo = file in photos[r]
        m = re.match(ANIM_REGEX, file)
        nochange_mask = None
        if is_anim and m.group(2):
            # and is not first frame
            n = int(m.group(2)[1:])
            n = list(anims[r][name].keys()).index(n)
            if n > 0:
                # get previous image path
                last = list(anims[r][name].keys())[n - 1]
                pre_file = anims[r][name][last][0]
                # open images
                img = np.array(Image.open(os.path.join(args.folder, file)).convert("RGBA"))
                pre_img = np.array(Image.open(os.path.join(args.folder, pre_file)).convert("RGBA"))
                # substract image from previous at tile level
                mask, nochange_mask = mask_per_tile(img, pre_img)
        # convertion
        if is_photo:
            img2snif(img_path, out, nb_bkg_pal=0, nb_spr_pal=9, no_bkg=True, no_spr_offset=True)
        elif is_anim:
            img2snif(img_path, out, nb_bkg_pal=6, nb_spr_pal=9, bkg_pal_offset=0, tile0_mask=nochange_mask)
        else:
            img2snif(img_path, out, nb_bkg_pal=6, nb_spr_pal=0, bkg_pal_offset=2)

print("Done!")
