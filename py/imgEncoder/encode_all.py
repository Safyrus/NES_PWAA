import argparse
import json
import os
import subprocess

from encode_frame import *
from img2bin import img2bin

CHR_START_BANK = 1
PRG_START_BANK = 0xC0
EMPTY_IMG = "../../data/empty.png"
IMG_NB_TILE = 256*3

warning_chr_size = False
warning_prg_size = False

# json structure
# [
#   {
#     "background": "img_path"
#     "character": [
#       "img_path",
#       "...",
#     ],
#     "time": [
#         16
#         ...,
#     ],
#     "palettes": [
#         [0, 0, 0, 0],
#         [0, 0, 0, 0, 0, 0]
#     ]
#   },
#   {
#     ...
#   },
#   ...
# ]


def encode_all(json, tile_bank, tile_maps, pal_maps, map_names):
    # prepare data
    frames = []
    frames_name = []
    frame_ischr = []
    anims = []
    spr_bank = [
        np.full((SPR_SIZE_H, SPR_SIZE_W), 0)
    ]
    pal_bank = []

    # get all file and check if there all exist
    print("check files")
    error = False
    for anim in json:
        # if background image does not exist
        if not os.path.exists(anim["background"]):
            print("ERROR: file", anim["background"], "does not exist")
            error = True
        for c in anim["character"]:
            # if character image does not exist
            if not os.path.exists(c):
                print("ERROR: file", c, "does not exist")
                error = True
    # if a file does not exist then stop here
    if error:
        exit(1)

    # for all animations:
    print("background encoding")
    for anim in json:
        # if background not already encoded
        if anim["background"] not in frames_name:
            # encode background as full image
            print("\033[A\033[2K\rencode background", anim["background"])
            pal_set = None
            if "palettes" in anim:
                pal_set = anim["palettes"]
            tile_map = tile_maps[map_names.index(anim["background"])]
            frame = encode_frame_bkg(anim["background"], tile_map, pal_bank, pal_set)
            # frames += frame
            frames.append(frame)
            frame_ischr.append(False)
            frames_name.append(anim["background"])
    print("\033[A\033[2K\rencoded all background")

    # for all animations:
    print("character encoding")
    spr_bnk_to_fix = {}
    for anim in json:
        # get animation info
        chars = anim["character"]
        times = anim["time"]
        bck = anim["background"]
        # skip if not a character
        if not chars:
            continue
        # init variables
        chars.append(chars[0])
        times.append(0)
        pal_set = anim["palettes"] if "palettes" in anim else None
        anim_frame = []
        last_char = bck
        # for all characters:
        for i in range(len(chars)):
            # get last character frame
            if i > 0:
                last_char = chars[i-1]
            anim_name = last_char + ";" + chars[i]
            # if not already encoded
            if anim_name not in frames_name:
                # encode character frame as partial image
                print("\033[A\033[2K\rencode character", anim_name)
                tile_map1_idx = map_names.index(last_char)
                tile_map2_idx = map_names.index(chars[i])
                tile_map1 = tile_maps[tile_map1_idx]
                tile_map2 = tile_maps[tile_map2_idx]
                pal_map1 = pal_maps[tile_map1_idx]
                pal_map2 = pal_maps[tile_map2_idx]
                frame, spr_bank, spr_data_bnk_idx = encode_frame_partial(bck, chars[i], spr_bank, pal_bank, pal_set, tile_map1, tile_map2, pal_map1, pal_map2)
                spr_bnk_to_fix[anim_name] = spr_data_bnk_idx
                # frames += frame
                frames.append(frame)
                frame_ischr.append(True)
                frames_name.append(anim_name)
            #
            anim_frame.append((anim_name, times[i] % 128))
        #
        anims.append(anim_frame)
    print("\033[A\033[2K\rencoded all character")

    print("fixing some bytes")
    offset = (len(tile_bank) // 16 // 256) + CHR_START_BANK
    for k, v in spr_bnk_to_fix.items():
        for i in range(len(frames)):
            if frames_name[i] == k:
                frames[i][v] += offset

    # make ca65 file
    print("ca65 file")
    ca65_inc = ".segment \"IMGS_BNK\"\n"
    ca65_bkg = "img_bkg_table:\n"
    ca65_bkg_bnk = "img_bkg_table_bank:\n"
    ca65_anim = "img_anim_table:\ndefault:\n.byte $01 ; size\n"
    chr_anims = {}
    PRG_size = 0
    for i in range(len(frames)):
        bank = (PRG_size // 8192) + PRG_START_BANK
        # include frames
        ca65_inc += "img_" + str(i) + ":\n.incbin \"imgs/img_" + str(i) + ".bin\" ;" + frames_name[i] + "\n"
        if frame_ischr[i]:
            # save character adr and bnk
            chr_adr = ".word (img_" + str(i) + " & $1FFF) + SEGMENT_IMGS_START_ADR ; " + frames_name[i] + "\n"
            chr_bnk = ".byte $" + hex(bank)[2:] + " ; bank\n"
            chr_anims[frames_name[i]] = chr_adr + chr_bnk
        else:
            # background index table
            ca65_bkg += ".word (img_" + str(i) + " & $1FFF) + SEGMENT_IMGS_START_ADR ; " + frames_name[i] + "\n"
            ca65_bkg_bnk += ".byte $" + hex(bank)[2:] + "\n"
        #
        frames[i] = bytes(frames[i])
        PRG_size += len(frames[i])
    for i, anim in enumerate(anims):
        ca65_anim += "img_anim_" + str(i) + ":\n.byte $" + "%0.2X" % ((len(anim) << 2)+1) + " ; size\n"
        for a in anim:
            ca65_anim += ".byte $" + "%0.2X" % a[1] + " ; time\n" + chr_anims[a[0]]
    ca65_pal = "palette_table:\n"
    for p in pal_bank:
        pal = ".byte"
        pal_cmt = " ;"
        for c in p:
            pal += f" $" + "%0.2X" % c + ","
            if c > 64:
                print(f"ERROR: wrong palette ({c})")
                pal_cmt += f" ERROR,"
            else:
                pal_cmt += f" {str(NES_PAL_NAM[c])}{str(NES_PAL[c])},"
        ca65_pal += pal[0:-1] + pal_cmt[0:-1] + "\n"
    ca65 = "; todo a description\n\n" + ca65_inc + "\n.segment \"CODE_BNK\"\n"
    ca65 += ca65_bkg + ca65_bkg_bnk + "\n" + ca65_anim + "\n" + ca65_pal + "\n"

    # tile_bank to ROM
    print("CHR ROM file")
    CHR_rom = []
    CHR_rom.extend(tile_bank)
    padding = len(CHR_rom) % 4096
    if padding != 0:
        CHR_rom.extend(bytes(4096-padding))
    for t in spr_bank:
        t1 = np.full((8, 8), 0)
        t2 = np.full((8, 8), 0)
        shape = np.shape(t[:8, :])
        t1[:shape[0], :shape[1]] = t[:8, :]
        shape = np.shape(t[8:16, :])
        t2[:shape[0], :shape[1]] = t[8:16, :]
        CHR_rom.extend(tile_2_chr(t1))
        CHR_rom.extend(tile_2_chr(t2))
    CHR_rom = bytes(CHR_rom)

    # return
    print("done")
    print("frames:", len(frames), "("+str(PRG_size)+" bytes)", " tiles:", len(CHR_rom)//16, "("+str(len(CHR_rom))+" bytes)")
    return ca65, frames, CHR_rom, PRG_size


def encode_frame_bkg(background, tile_map, pal_bank, pal_set):
    frame = []

    # FPTS ..BB
    # ||||   ++-- CHR bits for the MMC5 upper CHR Bank bits
    # |||+------- is Sprite map present ?
    # ||+-------- is Tile map present ?
    # |+--------- is Palette present ?
    # +---------- 1 = Full frame
    #             0 = partial frame
    flags = 0b11100000

    # read and convert image to index
    _, pal = bkg_col_reduce(background)
    if pal_set:
        pal = pal_set[0]
    # get image palette
    if pal not in pal_bank:
        pal_bank.append(pal)
    pal = pal_bank.index(pal)
    # convert tilemap to more compressable data (all low bytes, then all high bytes)
    data = []
    for t in tile_map:
        data.append(t % 256)
    for t in tile_map:
        data.append(((t//256) + CHR_START_BANK) % 64)
    # encode tilemap
    tile_map = rleinc_encode(data)

    # Byte 0: flags.
    frame.append(flags)

    # palette bytes
    frame.append(pal//256)
    frame.append(pal % 256)
    for _ in range(6):
        frame.append(0)

    # add tilemap to frame
    frame.extend(tile_map)

    return frame


def encode_frame_partial(background, character, spr_bank, pal_bank, pal_set, tile_map1, tile_map2, pal_map1, pal_map2):
    frame = []

    # Byte 0: flags.
    # FPTS ..BB
    # ||||   ++-- CHR bits for the MMC5 upper CHR Bank bits
    # |||+------- is Sprite map present ?
    # ||+-------- is Tile map present ?
    # |+--------- is Palette present ?
    # +---------- 1 = Full frame
    #             0 = partial frame
    flags = 0b01110000
    frame.append(flags)

    # get the full image of the previous and current frame
    spr_data2, spr_bank, pal_bkg, pal_chr = encode_frame(background, character, spr_bank)

    # get image background palette
    if pal_set:
        pal_bkg = pal_set[0]
        pal_chr = pal_set[1]
    if pal_bkg not in pal_bank:
        pal_bank.append(pal_bkg)
    pal_bkg_idx = pal_bank.index(pal_bkg)
    #
    pal_chr = [
        [pal_bkg[0], pal_chr[0], pal_chr[1], pal_chr[2]],
        [pal_bkg[0], pal_chr[0], pal_bkg[2], pal_bkg[3]],
        [pal_bkg[0], pal_chr[3], pal_chr[4], pal_chr[5]]
    ]
    for i in range(len(pal_chr)):
        if pal_chr[i] not in pal_bank:
            pal_bank.append(pal_chr[i])
        pal_chr[i] = pal_bank.index(pal_chr[i])
    # palette bytes
    frame.append(pal_bkg_idx//256)
    frame.append(pal_bkg_idx % 256)
    for p in pal_chr:
        frame.append(p//256)
        frame.append(p % 256)

    # remove same tiles between frames
    tile_map = []
    change_map = []
    for i in range(len(tile_map2)):
        change = tile_map1[i] != tile_map2[i] or pal_map1[i] != pal_map2[i]
        change_map.append(change)
        tile_map.append(tile_map2[i] if change else 0)

    # add sprites
    spr_map = []
    for i in range(4, len(spr_data2)):
        spr_map.append(spr_data2[i])

    # convert tilemap to more compressable data (all low bytes, then all high bytes)
    # and put pal map into tile map
    data = []
    for t in tile_map:
        data.append(t % 256)
    for i in range(len(tile_map)):
        t = (tile_map[i] // 256) + CHR_START_BANK
        p = pal_map2[i] << 6
        data.append((t % 64) + p if change_map[i] else 0)
    # encode data with RLE_INC
    tile_map = rleinc_encode(data)
    for i in range(len(spr_map)):
        if spr_map[i] > 255:
            print("ERROR: ", i, spr_map[i])
    spr_map = rleinc_encode(spr_map)

    # add tilemap to frame
    frame.extend(tile_map)
    # add sprite data to frame
    spr_data_bnk_idx = len(frame) + 1
    frame.extend(spr_data2[0:4])
    frame.extend(spr_map)

    return frame, spr_bank, spr_data_bnk_idx


def write_files(ca65, frames, CHR_rom, basechr_file=None, chr_name="CHR.chr"):
    CHRbase = bytes()
    if basechr_file:
        with open(basechr_file, "rb") as f:
            CHRbase = f.read(CHR_START_BANK*4096)
    with open(chr_name, "wb") as f:
        f.write(CHRbase)
        f.write(CHR_rom)
    with open("imgs.asm", "w") as f:
        f.write(ca65)
    if not os.path.exists("imgs"):
        os.mkdir("imgs")
    for i in range(len(frames)):
        with open("imgs/img_"+str(i)+".bin", "wb") as f:
            f.write(frames[i])


def main():
    global MAX_PIXEL_DIFF

    # argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-j", "--json", dest="json", type=str, required=False, default="anim.json")
    parser.add_argument("-bc", "--base-chr", dest="basechr", type=str, required=False, default=None)
    parser.add_argument("-b", "--best", dest="best", type=bool, required=False, default=True)
    parser.add_argument("-cp", "--c-path", dest="cpath", type=str, required=False, default="c/")
    parser.add_argument("-exe", "--c-program-name", dest="exe", type=str, required=False, default="a.exe")
    parser.add_argument("-oc", "--output-char", dest="out_chr", type=str, required=False, default="CHR.chr")
    args = parser.parse_args()

    tile_chr_path = os.path.join(args.cpath, "CHR.chr")
    tile_maps_folder = os.path.join(args.cpath, "maps/")
    args.out = os.path.join(args.cpath, "imgs/")
    c_program = os.path.join(args.cpath, args.exe)

    max_chr_size = 1024*1024
    max_prg_size = 1024*512

    # read json
    with open(args.json) as f:
        jsonAnim = json.load(f)

    ca65, frames, CHR_rom = "", [], bytes()

    # transform all images to binary
    img_names, pal_maps = img2bin(args)
    img_names = [n for n, _ in img_names]

    dif = 0
    while True:
        set_pixel_diff(dif)
        set_spr_pixel_diff(dif)

        # execute C program to convert binary images to CHR
        if not os.path.exists(tile_maps_folder):
            os.mkdir(tile_maps_folder)
        proc_info = subprocess.run([c_program, str(len(img_names)), "CHR.chr", str(dif)], cwd=args.cpath)
        if proc_info.returncode:
            exit(proc_info.returncode)

        # read tile bank file
        with open(tile_chr_path, "rb") as f:
            tile_bank = f.read()
        # read tile maps files
        nb_maps = len(os.listdir(tile_maps_folder))
        tile_maps = []
        for i in range(nb_maps):
            name = os.path.join(tile_maps_folder, str(i) + ".bin")
            # read one tile map files
            tile_map = []
            with open(name, "rb") as f:
                for _ in range(IMG_NB_TILE):
                    val = int.from_bytes(f.read(2), "little")
                    tile_map.append(val)
            tile_maps.append(tile_map)

        # encode all
        ca65, frames, CHR_rom, PRG_size = encode_all(jsonAnim, tile_bank, tile_maps, pal_maps, img_names)

        if not args.best or (PRG_size <= max_prg_size and len(CHR_rom) <= max_chr_size):
            break

        dif += 1
        set_pixel_diff(dif)
        print()
        print("*"*52)
        print("Final data too large. Try with pixel difference of", dif)
        print("*"*52)

    # write results
    write_files(ca65, frames, CHR_rom, args.basechr, args.out_chr)


if __name__ == "__main__":
    main()
