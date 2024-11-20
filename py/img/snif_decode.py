import argparse
import json
import numpy as np
from tile import chr2tiles
from rle_inc import rleinc_decode
from const import *


def print_nesimg(img):
    for line in img:
        print("".join([chr(x + 32) for x in line]))


def snif_decode_meta(data):
    i = 0
    while i < len(data) and data[i] != ord("}"):
        i += 1
    i += 1
    if i < len(data):
        metadata = json.loads(data[:i])
        return metadata, i
    return {}, 0


def snif_decode_pal(data, i):
    backdrop = data[i] & 0x3F
    bkg_palettes = [[], [], [], []]
    spr_palettes = [[], [], [], []]
    next = data[i] & 0x80
    i += 1
    while next:
        next = data[i] & 0x80
        p = [backdrop, data[i] & 0x3F, data[i + 1] & 0x3F, data[i + 2] & 0x3F]
        j = data[i + 1] >> 6
        if data[i] & 0x40:
            spr_palettes[j] = p
        else:
            bkg_palettes[j] = p
        i += 3
    palettes = bkg_palettes
    palettes.extend(spr_palettes)
    return palettes, i


def snif_decode_spr(data, i, w, h):
    spr_data = []
    end = False
    cur_pos = 0
    cur_pal = 0
    while not end:
        b = data[i]
        if b & 0x80:
            spr_y = data[i] & 0x0F
            spr_x = (data[i] >> 4) & 0x07
            spr_t = data[i + 1]
            spr = [
                (cur_pos % w) * 8 + spr_x,
                ((cur_pos // w) % h) * 16 + spr_y,
                spr_t,
                cur_pal,
                False,  # horizontal flip
                False,  # vertical flip
            ]
            spr_data.append(spr)
            cur_pos += 1
            i += 2
        else:
            b &= 0x7F
            if b == SPRCMD_END:
                end = True
            elif b & 0xFC == SPRCMD_PAL:
                cur_pal = b & 0x03
            elif b & 0xFC == SPRCMD_POS:
                x = (data[i] & 0x01) << 4
                y = ((data[i] >> 1) & 0x01) << 4
                i += 1
                x += (data[i] >> 4) & 0x0F
                y += data[i] & 0x0F
                cur_pos = y * w + x
            i += 1
    return spr_data, i


def snif_decode_data(data, i):
    # header
    header = data[i : i + 2]
    w = (header[0] & 0x1F) + 1
    h = (header[1] & 0x1F) + 1
    r = (header[0] & 0x60) >> 5
    c = (header[0] & 0x80) >> 7
    header = {"w": w, "h": h, "r": r, "c": c}
    i += 2
    # palette
    palettes, i = snif_decode_pal(data, i)
    # CHR bnk
    chr_bnk_mask = data[i]
    i += 1
    bnks = []
    while len(bnks) < 8:
        if chr_bnk_mask & 1:
            b = data[i]
            i += 1
            bnks.append(b)
        else:
            bnks.append(-1)
        chr_bnk_mask >>= 1
    # BKG data
    if header["c"]:
        tile_lo, size = rleinc_decode(data[i:])
        i += size
        tile_hi, size = rleinc_decode(data[i:])
        i += size
    else:
        tile_lo = data[i : i + w * h]
        i += w * h
        tile_hi = data[i : i + w * h]
        i += w * h
    tile_hi = np.array(list(tile_hi), dtype=np.uint16)
    tile_lo = np.array(list(tile_lo), dtype=np.uint16)
    bkg_adr = ((tile_hi & 0x3F) << 8) + tile_lo
    bkg_pal = tile_hi >> 6
    # SPR data
    spr_data, i = snif_decode_spr(data, i, w, h)

    return {
        "header": header,
        "pal": palettes,
        "bnk": bnks,
        "bkg_adr": bkg_adr,
        "bkg_pal": bkg_pal,
        "spr_data": spr_data,
    }, i


def snif_decode(data):
    # metadata
    metadata, i = snif_decode_meta(data)
    imgs = []
    # data for each image
    for _ in range(metadata["nbimg"]):
        img_data, i = snif_decode_data(data, i)
        imgs.append(img_data)
    # CHR
    tiles = chr2tiles(data[i:])

    return {
        "meta": metadata,
        "imgs": imgs,
        "chr": tiles,
    }


if __name__ == "__main__":
    # Argmuents
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", required=True)
    args = parser.parse_args()

    # read file
    with open(args.input, "rb") as f:
        data = f.read()
    # decode file
    data = snif_decode(data)
    #
    print("Metadata:", data["meta"])
    print("CHR shape:", data["chr"].shape)
    print("Images:")
    for img in data["imgs"]:
        print("Header:", img["header"])
        w, h = img["header"]["w"], img["header"]["h"]
        print("pal:", img["pal"])
        print("bnk:", img["bnk"])
        print("sprite count:", len(img["spr_data"]))
        print("#"*40)
        print("bkg_adr_lo:")
        print_nesimg((img["bkg_adr"] & 0xFF).reshape(h,w))
        print("#"*40)
        print("bkg_adr_hi:")
        print_nesimg((img["bkg_adr"] >> 8).reshape(h,w))
        print("#"*40)
        print("bkg_pal:")
        print_nesimg((img["bkg_pal"]).reshape(h,w))
        print("#"*40)
