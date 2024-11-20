import argparse
import hashlib
import os
import re
import numpy as np
from glob import glob
from tqdm import tqdm
from img2snif import img2snif
from compact import compact, CantFit
from PIL import Image
from const import *
from snif_decode import snif_decode_meta

DEFAULT_TIME = 30
NB_REGION = 4
ANIM_AFTERIDX_REGEX = r"(t[0-9]+).png"
ANIM_AFTERNAME_REGEX = r"_(i[0-9]+)(t[0-9]+)?.png"
ANIM_REGEX = r"(.*)_(i[0-9]+)(t[0-9]+)?.png"
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
    name = re.sub(r"[^a-zA-Z0-9-]+", "_", name)
    return name.upper()


def mask_per_tile(a, b):
    mask = np.all(a == b, axis=-1)
    w, h = mask.shape
    w = (w // 8) + (w % 8 != 0)
    h = (h // 8) + (h % 8 != 0)
    mask = mask.reshape(h, 8, w, 8).swapaxes(1, 2).reshape(h * w, 8, 8)
    mask = np.all(mask, axis=(-2, -1))
    mask = np.repeat(mask, 8).reshape(w, 8 * h)
    mask = np.repeat(mask, 8, axis=0)
    return mask


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
    all_files[r] = sorted(all_files[r])

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
all_files_idx = {}
# for each region
i = 0
for r in range(NB_REGION):
    anims.append({})
    # for each file
    fi = 0
    while fi < len(all_files[r]):
        file = all_files[r][fi]
        all_files_idx[file] = i
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
        #
        ori_img = np.array(Image.open(os.path.join(args.folder, file)).convert("RGBA"))
        img_idx = -1
        for j, a in anims[r][name].items():
            img = a[2]
            if np.all(img == ori_img):
                img_idx = j
                break
        if img_idx < 0:
            anims[r][name][idx] = (file, time, ori_img)
        else:
            anims[r][name][idx] = (anims[r][name][img_idx][0], time, anims[r][name][img_idx][2])
            # delete this image
            del all_files_idx[file]
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
    bar = tqdm(all_files[r], desc=f"Converting region {r}...")
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
        if is_anim and m.group(2):
            # and is not first frame
            n = int(m.group(2)[1:])
            n = list(anims[r][name].keys()).index(n)
            is_anim = False
            if n > 0:
                # get previous image path
                last = list(anims[r][name].keys())[n - 1]
                pre_file = anims[r][name][last][0]
                # open images
                img = np.array(Image.open(os.path.join(args.folder, file)).convert("RGBA"))
                pre_img = np.array(Image.open(os.path.join(args.folder, pre_file)).convert("RGBA"))
                # substract image from previous at tile level
                mask = mask_per_tile(img, pre_img)
                img[mask] = np.array([0, 0, 0, 0])
                # save as temporary image
                tmp_file = open("tmp.png", "wb")
                Image.fromarray(img).save("tmp.png")
                tmp_file.flush()
                tmp_file.close()
                #
                # temporary image convertion
                img_path = "tmp.png"
                is_anim = True
        # convertion
        img2snif(img_path, out)#, force=is_anim)


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
            main_snif_file, images_offset, chr_offset = compact(snif_files[r], n_region=1, reg_offset=r, MIN_PIXEL_EQUALITY=min_px, add_size=True)
            done = True
        except CantFit:
            if min_px < 16:
                print(f"Error: Can't fit all images in region {r} without making pixel porridge.")
                print(f"       Try to reassign images to other regions.")
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
filepath = os.path.join(args.output_folder, "all.CHR")
with open(filepath, "wb") as f:
    for r in range(NB_REGION):
        f.write(main_files[r][chr_offsets[r] :])

# Write raw image data file
filepath = os.path.join(args.output_folder, "img_data.bin")
with open(filepath, "wb") as f:
    for r in range(NB_REGION):
        f.write(main_files[r][: chr_offsets[r]])

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
            f.write(len(idx).to_bytes(1))
            n += 1
            for a in idx.values():
                f.write(all_files_idx[a[0]].to_bytes(1))
                f.write(a[1].to_bytes(1))
                n += 2

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
    # comment header
    f.write("; ################\n")
    f.write("; File: Image Pointers\n")
    f.write("; ################\n")
    f.write("; Note: This file was generated\n\n")
    # compute pointers
    low_str = ""
    high_str = ""
    bnk_str = ""
    reg_offset = 0
    i = 0
    for r in range(NB_REGION):
        for img_offset in img_offsets[r]:
            if i % 256 == 0:
                low_str += f".byte ({img_offset+reg_offset} >> 0) & $FF\n"
                high_str += f".byte ({img_offset+reg_offset} >> 8) & $1F\n"
                bnk_str += f".byte ({img_offset+reg_offset} >> 13) & $7F\n"
            i += 1
        reg_offset += chr_offsets[r]
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
            high_str += f".byte ({a} >> 8) & $1F\n"
            bnk_str += f".byte ({a} >> 13) & $7F\n"
    # write pointers
    f.write(f"img_ptr_list_lo:\n{low_str}\n")
    f.write(f"img_ptr_list_hi:\n{high_str}\n")
    f.write(f"img_ptr_list_bnk:\n{bnk_str}\n")


print("Done!")
