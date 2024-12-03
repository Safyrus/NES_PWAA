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
parser.add_argument("-of", "--output_folder", default="out")
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

# Remove output from files if it was found
for r in range(NB_REGION):
    if os.path.join(args.output_folder, f"r{r}.snif") in all_files[r]:
        idx = all_files[r].index(args.output_folder)
        del all_files[r][idx]
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
        # add it to animation list
        name = path2name(file)
        if name not in anims[r]:
            anims[r][name] = {}
        # get image as array
        ori_img = np.array(Image.open(os.path.join(args.folder, file)).convert("RGBA"))
        # get previous animation image as array
        prev_img = np.zeros(ori_img.shape)
        if len(anims[r][name]) > 0:
            last_idx = max(anims[r][name].keys())
            if idx > last_idx:
                prev_img = anims[r][name][last_idx][2]
        # compute difference between the two
        dif_img = abs(ori_img - prev_img)
        # compare to previous image in animation
        img_idx = -1
        for j, a in anims[r][name].items():
            img = a[3]
            if np.all(img == dif_img):
                img_idx = j
                break
        # if the image is unique
        if img_idx < 0:
            # add it to the aniamtion
            anims[r][name][idx] = (file, time, ori_img, dif_img)
        else:
            # else replace it with found image
            anims[r][name][idx] = (
                anims[r][name][img_idx][0],
                time,
                anims[r][name][img_idx][2],
                anims[r][name][img_idx][3],
            )
            del all_files[r][fi]
            i -= 1
            fi -= 1
        fi += 1

# sort animations indexs
for r in range(NB_REGION):
    for name in anims[r].keys():
        anims[r][name] = dict(sorted(anims[r][name].items()))

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
        if is_anim:
            img2snif(img_path, out, nb_bkg_pal=6, nb_spr_pal=9, bkg_pal_offset=0, tile0_mask=nochange_mask)
        else:
            img2snif(img_path, out, nb_bkg_pal=6, nb_spr_pal=0, bkg_pal_offset=2)


################################
# Compression
################################

# Compact images
main_files = []
img_offsets = []
chr_offsets = []
for r in range(NB_REGION):
    print(f"Compact region {r}...")
    min_px = DEFAULT_PX_EQUA
    done = False
    while not done:
        try:
            reserved_tiles = 5
            if r == 0:
                reserved_tiles = max(2, RES_FIRST_CHR_BYTES // 16)
            main_snif_file, images_offset, chr_offset = compact(
                snif_files[r],
                n_region=1,
                reg_offset=r,
                MIN_PIXEL_EQUALITY=min_px,
                add_size=True,
                reserved_tiles=reserved_tiles,
            )
            done = True
        except CantFit:
            if min_px < 32:
                print(f"Error: Can't fit all images in region {r} without making pixel porridge.")
                print(f"       Try to reassign images to other regions,")
                print(f"       or redesign your images to take less tiles.")
                exit(1)
            min_px -= 1
            print(f"Can't fit all images in region {r}. Retry with {64-min_px} pixel difference")
    main_files.append(main_snif_file)
    img_offsets.append(images_offset)
    chr_offsets.append(chr_offset)


################################
# Output Files
################################

# Create output folder
print("Output files")
os.makedirs(args.output_folder, exist_ok=True)

# Write output snif files
for r in range(NB_REGION):
    filepath = os.path.join(args.output_folder, f"r{r}.snif")
    with open(filepath, "wb") as f:
        nb_image = len(img_offsets[r])
        metadata = f'{{"version":0,"mapper":5,"nbimg":{nb_image}}}'
        f.write(bytes(metadata, encoding="utf-8"))
        f.write(main_files[r])

# Write CHR file
filepath = os.path.join(args.output_folder, "all.chr")
with open(filepath, "wb") as f:
    for r in range(NB_REGION):
        if r == 0:
            f.write(main_files[r][chr_offsets[r] + RES_FIRST_CHR_BYTES :])
        else:
            f.write(main_files[r][chr_offsets[r] :])

# Write raw image data file
filepath = os.path.join(args.output_folder, "img_data.bin")
all_files_idx = {}
with open(filepath, "wb") as f:

    def write_anim_or_bnk(isanim, idx):
        for r in range(NB_REGION):
            for i, file in enumerate(all_files[r]):
                if (path2name(file) in anims[r]) == isanim:
                    all_files_idx[file] = idx
                    idx += 1
                    start = img_offsets[r][i]
                    end = chr_offsets[r]
                    if i + 1 < len(img_offsets[r]):
                        end = img_offsets[r][i + 1]
                    f.write(main_files[r][start:end])
        return idx

    idx = 0
    idx = write_anim_or_bnk(False, idx)
    idx = write_anim_or_bnk(True, idx)

# Write raw animation data file
anims_idx = {}
anims_adr = []
filepath = os.path.join(args.output_folder, "anim_data.bin")
with open(filepath, "wb") as f:
    i = 0
    n = 0
    for r in range(NB_REGION):
        for name, idx in anims[r].items():
            anims_idx[name] = i
            anims_adr.append(n)
            i += 1
            # write animation bytes
            l = (len(idx) * 3) + 1
            f.write(l.to_bytes(1))
            n += 1
            for a in idx.values():
                f.write(all_files_idx[a[0]].to_bytes(2, "little"))
                f.write(a[1].to_bytes(1))
                n += 3

# Write image constant file
filepath = os.path.join(args.output_folder, "img_names.asm")
with open(filepath, "w") as f:
    # comment header
    f.write("; ################\n")
    f.write("; File: Image Names Constant\n")
    f.write("; ################\n")
    f.write("; Note: This file was generated\n\n")
    #
    for r in range(NB_REGION):
        for file in all_files[r]:
            name = path2name(file, anim_idx=True)
            f.write(f"{name} = {all_files_idx[file]}\n")

# Write image pointer file
filepath = os.path.join(args.output_folder, "img_ptr.asm")
with open(filepath, "w") as f:
    def write_anim_or_bnk(isanim, idx, low_str, high_str, bnk_str, size):
        for r in range(NB_REGION):
            for i, file in enumerate(all_files[r]):
                if (path2name(file) in anims[r]) == isanim:
                    if idx % 256 == 0:
                        low_str += f".byte ({size} >> 0) & $FF\n"
                        high_str += f".byte (({size} >> 8) & $1F) + $A0\n"
                        bnk_str += f".byte (({size} >> 13) & $7F) + IMG_BNK\n"
                    start = img_offsets[r][i]
                    end = chr_offsets[r]
                    if i + 1 < len(img_offsets[r]):
                        end = img_offsets[r][i + 1]
                    size += end-start
                    idx += 1
        return idx, low_str, high_str, bnk_str, size

    # comment header
    f.write("; ################\n")
    f.write("; File: Image Pointers\n")
    f.write("; ################\n")
    f.write("; Note: This file was generated\n\n")
    # compute pointers
    low_str = ""
    high_str = ""
    bnk_str = ""
    size = 0
    idx = 0
    idx, low_str, high_str, bnk_str, size = write_anim_or_bnk(False, idx, low_str, high_str, bnk_str, size)
    idx, low_str, high_str, bnk_str, size = write_anim_or_bnk(True, idx, low_str, high_str, bnk_str, size)
    # write pointers
    f.write(f"img_ptr_list_lo:\n{low_str}\n")
    f.write(f"img_ptr_list_hi:\n{high_str}\n")
    f.write(f"img_ptr_list_bnk:\n{bnk_str}\n")

# Write animation constant file
filepath = os.path.join(args.output_folder, "anim_names.asm")
with open(filepath, "w") as f:
    # comment header
    f.write("; ################\n")
    f.write("; File: Animation Names Constant\n")
    f.write("; ################\n")
    f.write("; Note: This file was generated\n\n")
    #
    for r in range(NB_REGION):
        for name, val in anims[r].items():
            f.write(f"{name} = {anims_idx[name]}\n")

# Write animation pointer file
filepath = os.path.join(args.output_folder, "anim_ptr.asm")
with open(filepath, "w") as f:
    # comment header
    f.write("; ################\n")
    f.write("; File: Animation Pointers\n")
    f.write("; ################\n")
    f.write("; Note: This file was generated\n\n")
    # compute pointers
    low_str = ""
    high_str = ""
    bnk_str = ""
    for i, a in enumerate(anims_adr):
        if i % 256 == 0:
            low_str += f".byte ({a} >> 0) & $FF\n"
            high_str += f".byte (({a} >> 8) & $1F) + $A0\n"
            bnk_str += f".byte (({a} >> 13) & $7F) + ANI_BNK\n"
    # write pointers
    f.write(f"anim_ptr_list_lo:\n{low_str}\n")
    f.write(f"anim_ptr_list_hi:\n{high_str}\n")
    f.write(f"anim_ptr_list_bnk:\n{bnk_str}\n")


print("Done!")
