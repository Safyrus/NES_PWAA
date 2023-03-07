import sys
import json
import os

from encode_frame import *

CHR_START_BANK = 1
PRG_START_BANK = 0xC0
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


def warning_CHR_size(tile_bank, spr_bank):
    global warning_chr_size
    if (len(tile_bank) + len(spr_bank)) >= 65536 and not warning_chr_size:
        print("WARNING: CHR size is bigger than 1 MB !")
        warning_chr_size = True


def warning_PRG_size(PRG_size):
    global warning_prg_size
    if PRG_size >= 1024*1024 and not warning_prg_size:
        print("WARNING: PRG size is bigger than 1 MB !")
        warning_prg_size = True


def encode_all(json):
    # prepare data
    frames = []
    frames_name = []
    frame_ischr = []
    anims = []
    tile_bank = [
        np.full((TILE_SIZE, TILE_SIZE), 0),
        np.full((TILE_SIZE, TILE_SIZE), 1),
        np.full((TILE_SIZE, TILE_SIZE), 2),
        np.full((TILE_SIZE, TILE_SIZE), 3),
    ]
    spr_bank = [
        np.full((SPR_SIZE_H, SPR_SIZE_W), 0)
    ]
    pal_bank = []

    # check if all file exists
    print("check files")
    for anim in json:
        if not os.path.exists(anim["background"]):
            print("ERROR: file", anim["background"], "does not exist")
            return "", frames, bytes()
        for c in anim["character"]:
            if not os.path.exists(c):
                print("ERROR: file", c, "does not exist")
                return "", frames, bytes()

    # for all animations:
    print("background encoding")
    for anim in json:
        warning_CHR_size(tile_bank, spr_bank)
        # if background not already encoded
        if anim["background"] not in frames_name:
            # encode background as full image
            print("encode background", anim["background"])
            pal_set = None
            if "palettes" in anim:
                pal_set = anim["palettes"]
            frame, tile_bank = encode_frame_bkg(anim["background"], tile_bank, pal_bank, pal_set)
            # frames += frame
            frames.append(frame)
            frame_ischr.append(False)
            frames_name.append(anim["background"])

    # for all animations:
    print("character encoding")
    spr_bnk_to_fix = {}
    for anim in json:
        warning_CHR_size(tile_bank, spr_bank)
        # for all characters:
        chars = anim["character"]
        times = anim["time"]
        bck = anim["background"]
        pal_set = None
        if "palettes" in anim:
            pal_set = anim["palettes"]
        anim_frame = []
        last_char = EMPTY_IMG
        for i in range(len(chars)):
            # get last character frame
            if i > 0:
                last_char = chars[i-1]
            anim_name = last_char + ";" + chars[i]
            # if not already encoded
            if anim_name not in frames_name:
                # encode character frame as partial image
                print("encode character", anim_name)
                frame, tile_bank, spr_bank, spr_data_bnk_idx = encode_frame_partial(
                    bck, chars[i], last_char, tile_bank, spr_bank, pal_bank, pal_set)
                spr_bnk_to_fix[anim_name] = spr_data_bnk_idx
                # frames += frame
                frames.append(frame)
                frame_ischr.append(True)
                frames_name.append(anim_name)
            anim_frame.append((anim_name, times[i] % 128))
        if anim_frame:
            anims.append(anim_frame)

    print("fixing some bytes")
    offset = (len(tile_bank) // 256) + 1 + CHR_START_BANK
    for k,v in spr_bnk_to_fix.items():
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
        ca65_inc += "img_" + str(i) + ":\n.incbin \"imgs/img_" + \
            str(i) + ".bin\" ;" + frames_name[i] + "\n"
        if frame_ischr[i]:
            # save character adr and bnk
            chr_adr = ".word (img_" + str(i) + " & $FFFF) ; " + frames_name[i] + "\n"
            chr_bnk = ".byte $" + hex(bank)[2:] + " ; bank\n"
            chr_anims[frames_name[i]] = chr_adr + chr_bnk
        else:
            # background index table
            ca65_bkg += ".word (img_" + str(i) + " & $FFFF) ; " + frames_name[i] + "\n"
            ca65_bkg_bnk += ".byte $" + hex(bank)[2:] + "\n"
        #
        frames[i] = bytes(frames[i])
        PRG_size += len(frames[i])
        warning_PRG_size(PRG_size)
    i = 0
    for anim in anims:
        ca65_anim += "img_anim_" + str(i) + ":\n.byte $" + "%0.2X" %((len(anim) << 2)+1) + " ; size\n"
        for a in anim:
            ca65_anim += ".byte $" + "%0.2X" % a[1] + " ; time\n" + chr_anims[a[0]]
        i += 1
    ca65_pal = "palette_table:\n"
    for p in pal_bank:
        pal = ".byte"
        pal_cmt = " ;"
        for c in p:
            pal += f" $" + "%0.2X" % c + ","
            pal_cmt += f" {str(NES_PAL_NAM[c])}{str(NES_PAL[c])},"
        ca65_pal += pal[0:-1] + pal_cmt[0:-1] + "\n"
    ca65 = "; todo a description\n\n" + ca65_inc + "\n.segment \"CODE_BNK\"\n"
    ca65 += ca65_bkg + ca65_bkg_bnk + "\n" + ca65_anim + "\n" + ca65_pal + "\n"

    # tile_bank to ROM
    print("CHR ROM file")
    CHR_rom = []
    for t in tile_bank:
        CHR_rom.extend(tile_2_chr(t))
    padding = len(CHR_rom) % 4096
    if padding != 0:
        CHR_rom.extend(bytes(4096-padding))
    for t in spr_bank:
        t1 = np.full((8, 8), 0)
        t2 = np.full((8, 8), 0)
        shape = np.shape(t[:8, :])
        t1[:shape[0],:shape[1]] = t[:8, :]
        shape = np.shape(t[8:16, :])
        t2[:shape[0],:shape[1]] = t[8:16, :]
        CHR_rom.extend(tile_2_chr(t1))
        CHR_rom.extend(tile_2_chr(t2))
    CHR_rom = bytes(CHR_rom)

    # return
    print("done")
    print("frames:", len(frames), "("+str(PRG_size)+" bytes)",
          " tiles:", len(CHR_rom)//16, "("+str(len(CHR_rom))+" bytes)")
    return ca65, frames, CHR_rom


def encode_frame_bkg(background, tile_bank, pal_bank, pal_set):
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

    # read and convert image to index
    background_img, pal = bkg_col_reduce_2(background)
    background_img = img_2_idx(background_img)
    if pal_set:
        pal = pal_set[0]
    # get image palette
    if pal not in pal_bank:
        pal_bank.append(pal)
    pal = pal_bank.index(pal)
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

    # palette bytes
    frame.append(pal//256)
    frame.append(pal%256)
    for _ in range(6):
        frame.append(0)

    # add tilemap to frame
    frame.extend(tile_map)

    return frame, tile_bank


def encode_frame_partial(background, character, last_character, tile_bank, spr_bank, pal_bank, pal_set):
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
    tile_map1, tile_bank, _, _, _, _, _, _ = encode_frame(
        background, last_character, tile_bank, spr_bank, CHR_START_BANK, False, False)
    tile_map2, tile_bank, _, spr_data2, spr_bank, pal_map, pal_bkg, pal_chr = encode_frame(
        background, character, tile_bank, spr_bank, CHR_START_BANK, False, False)

    # get image background palette
    if pal_set:
        pal_bkg = pal_set[0]
        pal_chr = pal_set[1]
    if pal_bkg not in pal_bank:
        pal_bank.append(pal_bkg)
    pal_bkg_idx = pal_bank.index(pal_bkg)
    #
    pal_chr = [
        [pal_bkg[0],pal_chr[0],pal_chr[1],pal_chr[2]],
        [pal_bkg[0],pal_chr[0], pal_bkg[2], pal_bkg[3]],
        [pal_bkg[0],pal_chr[3],pal_chr[4],pal_chr[5]]
    ]
    for i in range(len(pal_chr)):
        if pal_chr[i] not in pal_bank:
            pal_bank.append(pal_chr[i])
        pal_chr[i] = pal_bank.index(pal_chr[i])
    # palette bytes
    frame.append(pal_bkg_idx//256)
    frame.append(pal_bkg_idx%256)
    for p in pal_chr:
        frame.append(p//256)
        frame.append(p%256)

    # remove same tiles between frames
    tile_map = []
    change_map = []
    for i in range(len(tile_map2)):
        change = tile_map1[i] != tile_map2[i]
        change_map.append(change)
        if change:
            tile_map.append(tile_map2[i])
        else:
            tile_map.append(0)

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
        p = (pal_map[i] << 6)
        if change_map[i]:
            data.append((t % 64) + p)
        else:
            data.append(0)
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

    return frame, tile_bank, spr_bank, spr_data_bnk_idx


def write_files(ca65, frames, CHR_rom, basechr_file):
    CHRbase = bytes()
    if basechr_file:
        with open(basechr_file, "rb") as f:
            CHRbase = f.read(CHR_START_BANK*4096)
    with open("CHR.chr", "wb") as f:
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
    # args
    json_file = "anim.json"
    if len(sys.argv) > 1:
        json_file = sys.argv[1]
    basechr_file = ""
    if len(sys.argv) > 2:
        basechr_file = sys.argv[2]
    find_best_pixel_dif = False

    # read json
    with open(json_file) as f:
        jsonAnim = json.load(f)

    # encode all
    ca65, frames, CHR_rom = "", [], bytes()
    if find_best_pixel_dif:
        dif = 17
        while not warning_chr_size and not warning_prg_size and dif > 0:
            dif -= 1
            set_pixel_diff(dif)
            print()
            print("*"*40)
            print("Try with pixel difference of", dif)
            print("*"*40)
            ca65, frames, CHR_rom = encode_all(jsonAnim)
    else:
        ca65, frames, CHR_rom = encode_all(jsonAnim)
    write_files(ca65, frames, CHR_rom, basechr_file)


if __name__ == "__main__":
    main()
