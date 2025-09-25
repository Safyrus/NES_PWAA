import argparse
import hashlib
import os
import numpy as np
from img2neslimit_v2 import img2neslimit
from nes_pal import closest_nes_color
from rle_inc import RLEINC_CMD_END
from tile import tiles2chr
from const import *
from snif_decode import snif_decode_meta
from PIL import Image


def cut_into_pal(pal, backdrop):
    pals = [pal[i : i + PAL_SIZE] for i in range(0, len(pal), PAL_SIZE)]
    for p in pals:
        p.insert(0, backdrop)
    return pals


def find_tile_best_pal(tile, pals):
    # take unique colors in tile
    u = np.unique(tile)
    # count matching color per palette
    best_pal = []
    for p in pals:
        s = len(np.unique([c for c in p if c in u]))
        best_pal.append(s)
    # take palette with the most matchs
    if len(best_pal) == 0:
        return 0
    return np.argmax(best_pal)


def npimg2nes(img):
    for y in range(img.shape[0]):
        for x in range(img.shape[1]):
            if img[y][x][3] == 255:
                img[y][x][0] = closest_nes_color(img[y][x])
            else:
                img[y][x][0] = EMPTY_NES_COLOR
    img = img[:, :, 0]  # remove now useless channels
    return img


def bkg2tile(img, tw, th, pal, backdrop, w=8, h=8):
    # reshape image into tiles
    tile_data = img.reshape(th, h, tw, w).swapaxes(1, 2).reshape(th * tw, h, w)

    # Create address of each tile.
    # We use range because each tile is consider unique
    # and come one after the other
    tile_adr = np.arange(1, len(tile_data) + 1, dtype=np.uint16)

    # create NES palettes
    pals = cut_into_pal(pal, backdrop)

    # find palette for each tile
    tile_pal = []
    for i, t in enumerate(tile_data):
        # find palette for tile
        p = find_tile_best_pal(t, pals)
        # assign it
        tile_pal.append(p)
        # if tile is empty
        u = np.unique(t)
        if len(u) == 1 and u[0] == 63:
            # change tile to empty
            t[t == 63] = 0
            # and change address to special value
            tile_adr[i] = 0
        else:
            # replace tile color by palette index
            if p < len(pals):
                nt = t.copy()
                for j, c in enumerate(pals[p]):
                    assert j >= 0 and j < 4
                    nt[t == c] = j
                t = nt
        # update tile
        tile_data[i] = t
    # convert to numpy array
    tile_pal = np.array(tile_pal, dtype=np.uint8)

    # return tiles address, palettes and pixels
    return tile_adr, tile_pal, tile_data


def spr2data(spr, pal, w, h, backdrop):
    # create empty data array
    data = bytearray()
    # create NES palettes
    pals = cut_into_pal(pal, backdrop)
    # init position
    cur_pos = 0
    cur_pal = 0
    # for each sprite
    for i, s in enumerate(spr):
        # get current pos in tile
        cur_w = cur_pos % w
        cur_h = (cur_pos // w) % h
        # get sprite pos in tile
        spr_w = s[0] // 8
        spr_h = s[1] // 16
        # get sprite palette
        tile = npimg2nes(np.array(s[6]))
        spr_pal = find_tile_best_pal(tile, pals)
        # if sprite not in current tile
        if spr_w != cur_w or spr_h != cur_h:
            # add correct POS command
            cmd = SPRCMD_POS | (spr_h >= 16) << 1 | (spr_w >= 16)
            data.append(cmd)
            # add POS argument
            data.append((spr_w % 16) << 4 | (spr_h % 16))
            # change current pos
            cur_w = spr_w
            cur_h = spr_h
        # if palette has changed
        if spr_pal != cur_pal:
            # add PAL command
            data.append(SPRCMD_PAL + spr_pal)
            # change current palette
            cur_pal = spr_pal
        # get x and y offset from tile
        x = s[0] % 8
        y = s[1] % 16
        # add sprite bytes
        data.append(0x80 | (x << 4) | y)
        data.append(((i * 2) & 0xFE) + (1 if i >= 128 else 0))
        cur_pos += 1
    # add END command
    data.append(SPRCMD_END)

    return data


def spr2tile(pal, spr, backdrop):
    # create NES palettes
    pals = cut_into_pal(pal, backdrop)
    # for each sprite
    tiles = []
    for i, s in enumerate(spr):
        # get tile
        t = npimg2nes(np.array(s[6]))
        # find palette for tile
        p = find_tile_best_pal(t, pals)
        # replace tile color by palette index
        nt = t.copy()
        for j, c in enumerate(pals[p]):
            nt[t == c] = j
        t = nt
        # add tiles
        tiles.append(t[0:8, :])
        tiles.append(t[8:16, :])
    # return
    tiles = np.array(tiles)
    return tiles


def imgdata2snif(img_data, verbose=False, bkg_pal_offset=0, tile0_mask=None, no_bkg=False):
    snif_data = bytearray()

    ################
    # byte 0
    ################
    w = (img_data["w"] // 8) + int(img_data["w"] % 8 != 0) - 1
    assert 0 <= w < 32
    chr_region = 0
    compress_bkg = no_bkg
    b = w | (chr_region << 5) | (compress_bkg << 7)
    snif_data.append(b)

    ################
    # byte 1
    ################
    h = (img_data["h"] // 8) + int(img_data["h"] % 8 != 0) - 1
    assert 0 <= h < 30
    b = h
    snif_data.append(b)

    ################
    # palettes
    ################
    # convert palette to NES color
    bkg_pal = [closest_nes_color(x) for x in img_data["bkg_pal"]]
    spr_pal = [closest_nes_color(x) for x in img_data["spr_pal"]]
    backdrop = closest_nes_color(img_data["backdrop"])
    # assert palette size
    assert len(bkg_pal) <= PAL_SIZE * 4
    assert len(spr_pal) <= PAL_SIZE * 4
    # pad palette if needed
    while len(bkg_pal) % PAL_SIZE != 0:
        bkg_pal.append(BLACK_NES_COLOR)
    while len(spr_pal) % PAL_SIZE != 0:
        spr_pal.append(BLACK_NES_COLOR)
    # assert correct color
    for x in bkg_pal:
        assert 0 <= x < NB_NES_COLOR
    for x in spr_pal:
        assert 0 <= x < NB_NES_COLOR
    assert 0 <= backdrop < NB_NES_COLOR
    #
    if verbose:
        print("Backdrop:", backdrop)
        print("bkg_pal:", bkg_pal)
        print("spr_pal:", spr_pal)
    # add backdrop color
    nb_pal = len(bkg_pal) + len(spr_pal)
    snif_data.append(backdrop | ((nb_pal != 0) << 7))
    # add background colors
    for i in range(0, len(bkg_pal), PAL_SIZE):
        snif_data.append(0x80 | bkg_pal[i + 0])
        snif_data.append((((i // PAL_SIZE) + bkg_pal_offset) << 6) | bkg_pal[i + 1])
        snif_data.append(bkg_pal[i + 2])
    # add sprite colors
    for i in range(0, len(spr_pal), PAL_SIZE):
        snif_data.append(0xC0 | spr_pal[i + 0])
        snif_data.append(((i // PAL_SIZE) << 6) | spr_pal[i + 1])
        snif_data.append(spr_pal[i + 2])
    # remove next flag from last palette
    if nb_pal:
        snif_data[-3] &= 0x7F

    ################
    # PPU CHR banks
    ################
    # assert number of sprites
    snif_idx_chr_bnk = len(snif_data)
    spr = img_data["spr"]
    assert len(spr) <= 256
    # mask byte
    nb_bank = len(spr) // SPR_PER_BNK + (len(spr) % SPR_PER_BNK != 0)
    if verbose:
        print("Number of CHR BNK for sprites:", nb_bank)
    bnk_mask = (1 << nb_bank) - 1
    snif_data.append(bnk_mask)
    # bank bytes
    snif_data.extend(range(nb_bank))

    ################
    # BKG data
    ################
    if no_bkg:
        snif_data.append(RLEINC_CMD_END)
        snif_data.append(RLEINC_CMD_END)
    else:
        # convert image to tiles
        bkg_img = npimg2nes(np.array(img_data["bkg_img"]))
        tile_adr, tile_pal, tile_data = bkg2tile(bkg_img, w + 1, h + 1, bkg_pal, backdrop)
        if verbose:
            print("Number of tiles:", len(tile_data))
        #
        if np.any(tile0_mask):
            tile_adr[tile0_mask] = 0x4000
        # cut address in low and high part
        tile_adr_lo = np.array([x & 0xFF for x in tile_adr], dtype=np.uint8)
        tile_adr_hi = np.array([(x >> 8) for x in tile_adr], dtype=np.uint8)
        # assert lenght of arrays
        assert len(tile_pal) == len(tile_adr) == len(tile_data)
        # merge high address and palette to have MMC5 tiles
        for i in range(len(tile_adr_hi)):
            tile_adr_hi[i] |= (tile_pal[i] + bkg_pal_offset) << 6
        # add tile address to data
        snif_data.extend(tile_adr_lo)
        snif_data.extend(tile_adr_hi)

    ################
    # SPR data
    ################
    spr_data = spr2data(spr, spr_pal, w + 1, h + 1, EMPTY_NES_COLOR)
    if verbose:
        print("Number of sprites:", len(spr))
    snif_data.extend(spr_data)

    ################
    # BKG CHR
    ################
    if no_bkg:
        bkg_chr_size = 0
    else:
        # empty/null tile
        snif_data.extend(np.zeros(16, dtype=np.uint8))
        # add background tiles
        tile_chr = tiles2chr(tile_data)
        bkg_chr_size = len(tile_chr) + 16 # add empty/null tile size
        snif_data.extend(tile_chr)
        # compute padding
        padding = []
        if bkg_chr_size % BNK_SIZE:
            padding = np.zeros(BNK_SIZE - (bkg_chr_size % BNK_SIZE), dtype=np.uint8)
        # add padding
        snif_data.extend(padding)
        bkg_chr_size += len(padding)

    ################
    # SPR CHR
    ################
    spr_tiles = spr2tile(spr_pal, spr, EMPTY_NES_COLOR)
    snif_data.extend(tiles2chr(spr_tiles))

    ################
    # Fix offsets
    ################
    # fix CHR BNK
    offset = (bkg_chr_size // BNK_SIZE) + (bkg_chr_size % BNK_SIZE != 0)
    for i in range(nb_bank):
        snif_data[snif_idx_chr_bnk + 1 + i] += offset

    return snif_data


def img2snif(
    imgpath,
    outpath,
    verbose=False,
    force=False,
    nb_bkg_pal=2 * 3,
    nb_spr_pal=3 * 3,
    bkg_pal_offset=0,
    tile0_mask=None,
    no_bkg=False,
    no_spr_offset=False,
    bkg_pal=None,
):

    # if output already exist
    if not force and os.path.exists(outpath):
        # read metadata
        with open(outpath, "rb") as f:
            data = f.read()
        meta, _ = snif_decode_meta(data)
        # and if source image has not change since
        h = hashlib.sha256(Image.open(imgpath).tobytes()).hexdigest()
        if "hashori" in meta and h == meta["hashori"]:
            # then our work has already been done
            return False

    # convert image to image data
    if verbose:
        print("Convert Image to data")
    img_data = img2neslimit(
        img_path=imgpath,
        no_bkg=no_bkg,
        no_spr=nb_spr_pal == 0,
        no_spr_offset=no_spr_offset,
        bkg_pal=bkg_pal,
        verbose=verbose,
    )
    # convert image data to SNIF data
    if verbose:
        print("Convert data to SNIF")
    data = imgdata2snif(img_data, verbose=verbose, bkg_pal_offset=bkg_pal_offset, tile0_mask=tile0_mask, no_bkg=no_bkg)

    # metadata of file
    metadata = f'{{"version":0,"mapper":5,"nbimg":1,"hashori":"{img_data["hash"]}","havetile0mask":{0 if tile0_mask is None else 1}}}'

    # Write output file
    if verbose:
        print("Output file")
    if os.path.dirname(outpath):
        os.makedirs(os.path.dirname(outpath), exist_ok=True)
    with open(outpath, "wb") as f:
        f.write(bytes(metadata, encoding="utf-8"))
        f.write(data)

    if verbose:
        print("Done!")

    return True


if __name__ == "__main__":
    # Argmuents
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--image", required=True)
    parser.add_argument("-o", "--out", default="out.snif")
    parser.add_argument("-p", "--photo", action="store_true")
    args = parser.parse_args()

    if os.path.exists(args.out):
        os.remove(args.out)

    if args.photo:
        img2snif(args.image, args.out, verbose=True, nb_bkg_pal=0, nb_spr_pal=9, no_spr_offset=True, no_bkg=True)
    else:
        img2snif(args.image, args.out, verbose=True)
