import sys
import json
import os

from encode_frame import *

CHR_START_BANK = 0
PRG_START_BANK = 0x80
EMPTY_IMG = "../../data/empty.png"

warning_chr_size = False
warning_prg_size = False

# json structure
# [
#   {
#     "background": "img_path"
#     "character": [
#       "img_path",
#       "...",
#     ]
#   },
#   {
#     ...
#   },
#   ...
# ]

def warning_CHR_size(tile_bank, spr_bank):
    global warning_chr_size
    if (len(tile_bank) + len(spr_bank)) >= 65536 and not warning_chr_size:
        print("WARNING: CHR size is bigger than 1 MB !")
        warning_chr_size = True

def warning_PRG_size(PRG_size):
    global warning_prg_size
    if len(PRG_size) >= 1024*1024 and not warning_prg_size:
        print("WARNING: PRG size is bigger than 1 MB !")
        warning_prg_size = True


def encode_all(json):
    # prepare data
    frames = []
    frames_name = []
    frame_ischr = []
    tile_bank = [
        np.full((TILE_SIZE, TILE_SIZE), 0),
        np.full((TILE_SIZE, TILE_SIZE), 1),
        np.full((TILE_SIZE, TILE_SIZE), 2),
        np.full((TILE_SIZE, TILE_SIZE), 3),
    ]
    spr_bank = [
        np.full((SPR_SIZE_H, SPR_SIZE_W), 0),
        np.full((SPR_SIZE_H, SPR_SIZE_W), 1),
        np.full((SPR_SIZE_H, SPR_SIZE_W), 2),
        np.full((SPR_SIZE_H, SPR_SIZE_W), 3),
    ]

    # check if all file exists
    print("check files")
    for anim in json:
        if not os.path.exists(anim["background"]):
            print("ERROR: file", anim["background"], "does not exist")
            return
        for c in anim["character"]:
            if not os.path.exists(c):
                print("ERROR: file", c, "does not exist")
                return

    # for all animations:
    print("background encoding")
    for anim in json:
        warning_CHR_size(tile_bank, spr_bank)
        # if background not already encoded
        if anim["background"] not in frames_name:
            # encode background as full image
            print("encode background", anim["background"])
            frame, tile_bank = encode_frame_bkg(anim["background"], tile_bank)
            # frames += frame
            frames.append(frame)
            frame_ischr.append(False)
            frames_name.append(anim["background"])

    # for all animations:
    print("character encoding")
    for anim in json:
        warning_CHR_size(tile_bank, spr_bank)
        # for all characters:
        chars = anim["character"]
        bck = anim["background"]
        for i in range(len(chars)):
            # if not already encoded
            if chars[i] not in frames_name:
                # get last character frame or an empty image
                last_char = EMPTY_IMG
                if i > 0:
                    last_char = chars[i-1]
                # encode character as partial image
                print("encode character", chars[i])
                frame, tile_bank, spr_bank = encode_frame_partial(
                    bck, chars[i], last_char, tile_bank, spr_bank)
                # frames += frame
                frames.append(frame)
                frame_ischr.append(True)
                frames_name.append(chars[i])

    # make ca65 file
    print("ca65 file")
    ca65_inc = ""
    ca65_bkg = "img_bkg_table:\n"
    ca65_bkg_bnk = "img_bkg_table_bank:\n"
    ca65_chr = "img_chr_table:\n"
    ca65_chr_bnk = "img_chr_table_bank:\n"
    PRG_size = 0
    for i in range(len(frames)):
        bank = (PRG_size // 8192) + PRG_START_BANK
        # include frames
        ca65_inc += "img_" + str(i) + ":\n.incbin \"imgs/img_" + \
            str(i) + ".bin\" ;" + frames_name[i] + "\n"
        if frame_ischr[i]:
            # character index table
            ca65_chr += ".word img_" + str(i) + " ; " + frames_name[i] + "\n"
            ca65_chr_bnk += ".byte $" + hex(bank)[2:] + "\n"
        else:
            # background index table
            ca65_bkg += ".word img_" + str(i) + " ; " + frames_name[i] + "\n"
            ca65_bkg_bnk += ".byte $" + hex(bank)[2:] + "\n"
        #
        frames[i] = bytes(frames[i])
        PRG_size += len(frames[i])
        warning_PRG_size(PRG_size)
    ca65 = "; todo a description\n\n" + ca65_inc + "\n"
    ca65 += ca65_bkg + ca65_bkg_bnk + "\n" + ca65_chr + ca65_chr_bnk + "\n"

    # tile_bank to ROM
    print("CHR ROM file")
    CHR_rom = []
    for t in tile_bank:
        CHR_rom.extend(tile_2_chr(t))
    padding = len(CHR_rom) % 4096
    if padding != 0:
        CHR_rom.extend(bytes(4096-padding))
    for t in spr_bank:
        t1, t2 = t[0:8, :], t[8:16, :]
        CHR_rom.extend(tile_2_chr(t1))
        CHR_rom.extend(tile_2_chr(t2))
    CHR_rom = bytes(CHR_rom)

    # return
    print("done")
    return ca65, frames, CHR_rom


def encode_frame_bkg(background, tile_bank):
    frame = []

    # Byte 0: flags.
    # FPTS ..BB
    # ||||   ++-- CHR bits for the MMC5 upper CHR Bank bits
    # |||+------- is Sprite map present ?
    # ||+-------- is Tile map present ?
    # |+--------- is Palette present ?
    # +---------- 1 = Full frame
    #             0 = partial frame
    flags = 0b11100000
    frame.append(flags)

    # palette bytes
    for _ in range(8):
        frame.append(0)

    # read and convert image to index
    background_img = bkg_col_reduce_2(background)
    background_img = img_2_idx(background_img)
    # convert frame to tiles
    tile_set, tile_map = img_2_tile(background_img)
    # remove similar tiles
    _, tile_map, tile_bank = rm_closest_tiles(tile_set, tile_map, tile_bank)
    # convert tilemap to more compressable data (all low bytes, then all high bytes)
    data = []
    for t in tile_map:
        data.append(t % 256)
    for t in tile_map:
        data.append(((t//256) + CHR_START_BANK) % 64)
    # encode tilemap
    tile_map = rleinc_encode(data)

    # add tilemap to frame
    frame.extend(tile_map)

    return frame, tile_bank


def encode_frame_partial(background, character, last_character, tile_bank, spr_bank):
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

    # palette bytes
    for _ in range(8):
        frame.append(0)

    # get the full image of the previous and current frame
    tile_map1, tile_bank, _, spr_data1, spr_bank, _ = encode_frame(
        background, last_character, tile_bank, spr_bank, CHR_START_BANK, False, False)
    tile_map2, tile_bank, spr_info, spr_data2, spr_bank, pal_map = encode_frame(
        background, character, tile_bank, spr_bank, CHR_START_BANK, False, False)

    # remove same tiles between frames
    tile_map = []
    change_map = []
    for i in range(len(tile_map2)):
        change_map.append(tile_map1[i] != tile_map2[i])
        if tile_map1[i] == tile_map2[i]:
            tile_map.append(0)
        else:
            tile_map.append(tile_map2[i])

    # remove same sprites between frames
    spr_map = []
    for i in range(4, len(spr_data2)):
        if i < len(spr_data1) and spr_data1[i] == spr_data2[i]:
            spr_map.append(0)
        else:
            spr_map.append(spr_data2[i])

    # convert tilemap to more compressable data (all low bytes, then all high bytes)
    data = []
    for t in tile_map:
        data.append(t % 256)
    for t in tile_map:
        data.append(((t//256) + CHR_START_BANK) % 64)
    # put pal map into tile map
    for i in range(len(pal_map)):
        if change_map[i]:
            data[i+len(pal_map)] += (pal_map[i] << 6)
    # encode data with RLE_INC
    tile_map = rleinc_encode(data)
    spr_map = rleinc_encode(spr_map)

    # add tilemap to frame
    frame.extend(tile_map)
    # add sprite data to frame
    frame.extend(spr_data2[0:4])
    frame.extend(spr_map)

    return frame, tile_bank, spr_bank


if __name__ == "__main__":
    # args
    json_file = "anim.json"
    if len(sys.argv) > 1:
        json_file = sys.argv[1]

    # read json
    with open(json_file) as f:
        jsonAnim = json.load(f)

    # encode all
    ca65, frames, CHR_rom = encode_all(jsonAnim)

    # write files
    with open("CHR.chr", "wb") as f:
        f.write(CHR_rom)
    with open("imgs.asm", "w") as f:
        f.write(ca65)
    if not os.path.exists("imgs"):
        os.mkdir("imgs")
    for i in range(len(frames)):
        with open("imgs/img_"+str(i)+".bin", "wb") as f:
            f.write(frames[i])
