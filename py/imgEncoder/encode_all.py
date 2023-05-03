import argparse
import json
import os
import subprocess

from encode_frame import *
from img2bin import img2bin

EMPTY_IMG = "../../data/empty.png"
IMG_NB_TILE = 256*3
MAX_FRAME_IDX = 1000000

warning_chr_size = False
warning_prg_size = False


def ca65_file(frames, ca65_info, prg_start_bank=0):
    # get all data
    backgrounds_idx = ca65_info["frames_bkg_idx"]
    backgrounds_name = ca65_info["frames_bkg_name"]
    frames_ischr = ca65_info["ischr"]
    frames_name = ca65_info["names"]
    anims = ca65_info["anims"]
    anims_name = ca65_info["anims_name"]
    anims_idx = ca65_info["anims_idx"]
    pal_bank = ca65_info["pal_bank"]

    # sort backgrounds
    for i in range(len(frames)):
        # find min idx
        min_idx = i
        min_val = backgrounds_idx[i]
        for j in range(i+1, len(frames)):
            if backgrounds_idx[j] < min_val:
                min_idx, min_val = j, backgrounds_idx[j]
        # swap
        frames[i], frames[min_idx] = frames[min_idx], frames[i]
        frames_ischr[i], frames_ischr[min_idx] = frames_ischr[min_idx], frames_ischr[i]
        frames_name[i], frames_name[min_idx] = frames_name[min_idx], frames_name[i]
        backgrounds_idx[i], backgrounds_idx[min_idx] = backgrounds_idx[min_idx], backgrounds_idx[i]
        backgrounds_name[i], backgrounds_name[min_idx] = backgrounds_name[min_idx], backgrounds_name[i]

    # sort animations
    for i in range(len(anims)):
        # find min idx
        min_idx = i
        min_val = anims_idx[i]
        for j in range(i+1, len(anims)):
            if anims_idx[j] < min_val:
                min_idx, min_val = j, anims_idx[j]
        # swap
        anims[i], anims[min_idx] = anims[min_idx], anims[i]
        anims_idx[i], anims_idx[min_idx] = anims_idx[min_idx], anims_idx[i]
        anims_name[i], anims_name[min_idx] = anims_name[min_idx], anims_name[i]

    # init variables
    print("ca65 file")
    ca65_inc = ".segment \"IMGS_BNK\"\n"
    ca65_bkg = "img_bkg_table:\n"
    ca65_bkg_bnk = "img_bkg_table_bank:\n"
    ca65_anim = "img_anim_table:\ndefault:\n.byte $01 ; size\n"
    chr_anims = {}
    PRG_size = 0

    # write frames and tables
    for i in range(len(frames)):
        bank = (PRG_size // 8192) + prg_start_bank
        # include frames
        ca65_inc += "img_" + str(i) + ":\n.incbin \"imgs/img_" + str(i) + ".bin\" ;" + frames_name[i] + "\n"
        if frames_ischr[i]:
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
    
    # write animations table
    for i, anim in enumerate(anims):
        ca65_anim += "img_anim_" + str(i) + ":\n.byte $" + "%0.2X" % ((len(anim) << 2)+1) + " ; size\n"
        for a in anim:
            ca65_anim += ".byte $" + "%0.2X" % a[1] + " ; time\n" + chr_anims[a[0]]

    # write palettes table
    ca65_pal = "palette_table:\n"
    # for p in pal_bank:
    #     pal = ".byte"
    #     pal_cmt = " ;"
    #     for c in p:
    #         pal += f" $" + "%0.2X" % c + ","
    #         if c > 64:
    #             print(f"ERROR: wrong palette ({c})")
    #             pal_cmt += f" ERROR,"
    #         else:
    #             pal_cmt += f" {str(NES_PAL_NAM[c])}{str(NES_PAL[c])},"
    #     ca65_pal += pal[0:-1] + pal_cmt[0:-1] + "\n"

    # final touch
    ca65 = "; todo a description\n\n" + ca65_inc + "\n.segment \"CODE_BNK\"\n"
    ca65 += ca65_bkg + ca65_bkg_bnk + "\n" + ca65_anim + "\n" + ca65_pal + "\n"
    return ca65


def encode_all(json, tile_bank, tile_maps, pal_maps, map_names, pal_bank=[], chr_start_bank=0):
    # prepare data
    frames = []
    frames_name = []
    frames_ischr = []
    frames_bkg_idx = []
    frames_bkg_name = []
    anims = []
    anims_name = []
    anims_idx = []
    spr_bank = [
        np.full((SPR_SIZE_H, SPR_SIZE_W), 0)
    ]

    # get all files and check if their all exist
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
    # if a file does not exist, then stop here
    if error:
        exit(1)

    # for all animations:
    print("background encoding")
    for anim in json:
        # if background isn't already encoded
        if anim["background"] not in frames_name:
            # encode background as full image
            print("\033[A\033[2K\rencode background", anim["background"])
            pal_set = None
            if "palettes" in anim:
                pal_set = anim["palettes"]
            tile_map = tile_maps[map_names.index(anim["background"])]
            frame = encode_frame_bkg(anim["background"], tile_map, pal_bank, pal_set, chr_start_bank=chr_start_bank)
            # frames += frame
            frames.append(frame)
            frames_ischr.append(False)
            frames_name.append(anim["background"])
            frames_bkg_name.append(anim["name"] if "name" in anim else f"BKG_{len(frames_bkg_name)}")
            frames_bkg_idx.append(anim["idx"] if "idx" in anim else MAX_FRAME_IDX)
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
            #
            if "palettes_each" in anim:
                if i < len(anim["palettes_each"]):
                    pal_set = anim["palettes_each"][i]
                else:
                    pal_set = anim["palettes_each"][0]
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
                frame, spr_bank, spr_data_bnk_idx = encode_frame_partial(bck, chars[i], spr_bank, pal_bank, pal_set, tile_map1, tile_map2, pal_map1, pal_map2, chr_start_bank=chr_start_bank)
                spr_bnk_to_fix[anim_name] = spr_data_bnk_idx
                # frames += frame
                frames.append(frame)
                frames_ischr.append(True)
                frames_name.append(anim_name)
                frames_bkg_name.append("NONE")
                frames_bkg_idx.append(MAX_FRAME_IDX)
            #
            anim_frame.append((anim_name, times[i] % 128))
        #
        anims.append(anim_frame)
        anims_name.append(anim["name"] if "name" in anim else f"CHR_{len(anims_name)}")
        anims_idx.append(anim["idx"] if "idx" in anim else MAX_FRAME_IDX)
    print("\033[A\033[2K\rencoded all character")

    print("fixing some bytes")
    offset = (len(tile_bank) // 16 // 256) + chr_start_bank
    for k, v in spr_bnk_to_fix.items():
        for i in range(len(frames)):
            if frames_name[i] == k:
                frames[i][v] += offset

    # pack ca65 info
    ca65_info = {
        "frames_bkg_idx": frames_bkg_idx,
        "frames_bkg_name": frames_bkg_name,
        "ischr": frames_ischr,
        "names": frames_name,
        "anims": anims,
        "anims_name": anims_name,
        "anims_idx": anims_idx,
        "pal_bank": pal_bank
    }

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
    PRG_size = sum([len(f) for f in frames])
    print("done")
    print("frames:", len(frames), "("+str(PRG_size)+" bytes)", " tiles:", len(CHR_rom)//16, "("+str(len(CHR_rom))+" bytes)")
    return ca65_info, frames, CHR_rom


def encode_frame_bkg(background, tile_map, pal_bank, pal_set, chr_start_bank=0):
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
    # convert tilemap to more compressible data (all low bytes, then all high bytes)
    data = []
    for t in tile_map:
        data.append(t % 256)
    for t in tile_map:
        data.append(((t//256) + chr_start_bank) % 64)
    # encode tilemap
    tile_map = rleinc_encode(data)

    # Byte 0: flags.
    frame.append(flags)

    # palette bytes
    frame.extend(pal)
    frame.extend([0xFF]*3)
    frame.append(0xFF)
    frame.append(pal[2])
    frame.append(pal[3])
    frame.extend([0xFF]*3)

    # add tilemap to frame
    frame.extend(tile_map)

    return frame


def encode_frame_partial(background, character, spr_bank, pal_bank, pal_set, tile_map1, tile_map2, pal_map1, pal_map2, chr_start_bank=0):
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
    #
    pal_chr = [
        [pal_bkg[0], pal_chr[0], pal_chr[1], pal_chr[2]],
        [pal_bkg[0], pal_chr[0], pal_bkg[2], pal_bkg[3]],
        [pal_bkg[0], pal_chr[3], pal_chr[4], pal_chr[5]]
    ]
    for i in range(len(pal_chr)):
        if pal_chr[i] not in pal_bank:
            pal_bank.append(pal_chr[i])
    # palette bytes
    frame.extend([0xFF]*4)
    frame.extend(pal_chr[0][1:])
    frame.append(pal_chr[1][1])
    frame.extend([0xFF]*2)
    frame.extend(pal_chr[2][1:])

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

    # convert tilemap to more compressible data (all low bytes, then all high bytes)
    # and put the pal map into the tile map
    data = []
    for t in tile_map:
        data.append(t % 256)
    for i in range(len(tile_map)):
        t = (tile_map[i] // 256) + chr_start_bank
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


def write_files(ca65_info, frames, CHR_rom, basechr_file=None, chr_name="CHR.chr", asmfile="imgs.asm", imgfolder="imgs", prg_start_bank=0):
    #
    CHRbase = bytes()
    if basechr_file:
        with open(basechr_file, "rb") as f:
            CHRbase = f.read()
        if len(CHRbase) % 4096 != 0:
            CHRbase += bytes(4096 - (len(CHRbase) % 4096))
    #
    with open(chr_name, "wb") as f:
        f.write(CHRbase)
        f.write(CHR_rom)
    #
    with open(asmfile, "w") as f:
        ca65 = ca65_file(frames, ca65_info, prg_start_bank=prg_start_bank)
        f.write(ca65)
    #
    if not os.path.exists(imgfolder):
        os.mkdir(imgfolder)
    for i in range(len(frames)):
        with open(imgfolder + "/img_"+str(i)+".bin", "wb") as f:
            f.write(frames[i])
    #
    with open("const_info.txt", "w") as f:
        f.write("\n<!--Background constants:-->\n")
        count = 0
        for i in range(len(ca65_info["frames_bkg_name"])):
            name, idx = ca65_info["frames_bkg_name"][i], ca65_info["frames_bkg_idx"][i]
            if idx == MAX_FRAME_IDX:
                idx = count
            if name != "NONE":
                f.write(f"<const:{name}:{idx}>\n")
                count += 1
        #
        f.write("\n<!--Animation constants:-->\n")
        count = 0
        for i in range(len(ca65_info["anims_name"])):
            name, idx = ca65_info["anims_name"][i], ca65_info["anims_idx"][i]
            if idx == MAX_FRAME_IDX:
                idx = count
            if name != "NONE":
                f.write(f"<const:{name}:{idx%256}>\n")
                count += 1


def encode_all_constrain(args, json_anim, pal_bank=[]):
    # transform all images to binary
    img_names, pal_maps = img2bin(args)
    img_names = [n for n, _ in img_names]

    dif = args.start_dif
    while True:
        set_pixel_diff(dif)
        set_spr_pixel_diff(dif)

        # execute C program to convert binary images to CHR
        if not os.path.exists(args.tile_maps_folder):
            os.mkdir(args.tile_maps_folder)
        proc_info = subprocess.run([args.c_program, str(len(img_names)), "CHR.chr", str(dif)], cwd=args.cpath)
        if proc_info.returncode:
            exit(proc_info.returncode)

        # read tile bank file
        with open(args.tile_chr_path, "rb") as f:
            tile_bank = f.read()
        # read tile maps files
        nb_maps = len(os.listdir(args.tile_maps_folder))
        tile_maps = []
        for i in range(nb_maps):
            name = os.path.join(args.tile_maps_folder, str(i) + ".bin")
            # read one tile map files
            tile_map = []
            with open(name, "rb") as f:
                for _ in range(IMG_NB_TILE):
                    val = int.from_bytes(f.read(2), "little")
                    tile_map.append(val)
            tile_maps.append(tile_map)

        # encode all
        ca65_info, frames, CHR_rom = encode_all(json_anim, tile_bank, tile_maps, pal_maps, img_names, pal_bank=pal_bank, chr_start_bank=args.chr_start)

        PRG_size = sum([len(f) for f in frames])
        if PRG_size <= args.max_prg_size and len(CHR_rom) <= args.max_chr_size:
            return ca65_info, frames, CHR_rom
        if dif >= 64:
            print("/!\\ "*6)
            print(" Impossible. Abording")
            print("/!\\ "*6)
            return ca65_info, frames, CHR_rom

        dif += 1
        set_pixel_diff(dif)
        print()
        print("*"*52)
        print("Final data too large. Try with pixel difference of", dif)
        print("*"*52)


def main():
    global MAX_PIXEL_DIFF

    # argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-j", "--json", dest="json", type=str, required=False, default="anim.json")
    parser.add_argument("-bc", "--base-chr", dest="basechr", type=str, required=False, default=None)
    parser.add_argument("-cp", "--c-path", dest="cpath", type=str, required=False, default="c/")
    parser.add_argument("-exe", "--c-program-name", dest="exe", type=str, required=False, default="a.exe")
    parser.add_argument("-oc", "--output-char", dest="out_chr", type=str, required=False, default="CHR.chr")
    parser.add_argument("-mc", "--max-chr-size", dest="max_chr_size", type=int, required=False, default=1024*1024)
    parser.add_argument("-mp", "--max-prg-size", dest="max_prg_size", type=int, required=False, default=1024*512)
    parser.add_argument("-bsc", "--bank-start-chr", dest="chr_start", type=int, required=False, default=1)
    parser.add_argument("-bsp", "--bank-start-prg", dest="prg_start", type=int, required=False, default=0xC0)
    args = parser.parse_args()

    args.tile_chr_path = os.path.join(args.cpath, "CHR.chr")
    args.tile_maps_folder = os.path.join(args.cpath, "maps/")
    args.out = os.path.join(args.cpath, "imgs/")
    args.c_program = os.path.join(args.cpath, args.exe)

    # read json
    with open(args.json) as f:
        json_anim = json.load(f)

    ca65_info, frames, CHR_rom = encode_all_constrain(args, json_anim)

    # write results
    write_files(ca65_info, frames, CHR_rom, basechr_file=args.basechr, chr_name=args.out_chr, prg_start_bank=args.prg_start)


if __name__ == "__main__":
    main()
