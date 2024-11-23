from rle_inc import rleinc_encode
from const import *
import numpy as np


def snif_encode_pal(palettes):
    bin_data = bytearray()

    backdrop = [x[0] for x in palettes if x]
    if backdrop:
        backdrop = backdrop[0]
    else:
        backdrop = EMPTY_NES_COLOR

    bin_data.append(int(len(palettes) > 0) << 7 | backdrop & 0x3F)
    for i, p in enumerate(palettes):
        if not p:
            continue
        n = 0
        if i < 7:
            n = len([x for x in palettes[i + 1 :] if x]) > 0
        n <<= 7
        spr_pal = int(i >= 4) << 6
        bin_data.append(n | spr_pal | p[1])
        bin_data.append((i % 4) << 6 | p[2])
        bin_data.append(p[3])

    return bin_data


def snif_encode_spr(spr, w, h):
    xs = [x[0] for x in spr]
    ys = [x[1] for x in spr]
    ps = [x[3] for x in spr]
    hs = [x[4] for x in spr]
    vs = [x[5] for x in spr]
    idxs = np.lexsort((xs, ys, vs, hs, ps))
    data = bytearray()
    h = (h // 2) + (h % 2)

    cur_pos = 0
    cur_pal = 0
    cur_flip = [False, False]  # H,V
    for i in idxs:
        s = spr[i]
        # get current pos in tile
        cur_w = cur_pos % w
        cur_h = (cur_pos // w) % h
        # get sprite pos in tile
        spr_w = s[0] // 8
        spr_h = s[1] // 16
        # get sprite palette
        spr_pal = s[3]
        # Get sprite flip
        spr_flip = [s[4], s[5]]
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
        # if flip has changed
        if cur_flip != spr_flip:
            # add FLIP command
            data.append(SPRCMD_FLIP | int(spr_flip[1] << 1) | int(spr_flip[0]))
            # change current flip
            cur_flip = spr_flip
        # get x and y offset from tile
        x = s[0] % 8
        y = s[1] % 16
        # add sprite bytes
        data.append(0x80 | (x << 4) | y)
        data.append(s[2])
        cur_pos += 1
    # add END command
    data.append(SPRCMD_END)
    return data


def snif_encode_data(data):
    bin_data = bytearray()

    # header
    w = data["header"]["w"] - 1
    h = data["header"]["h"] - 1
    r = data["header"]["r"]
    assert 0 <= w <= 31
    assert 0 <= h <= 29
    compressed = 1
    bin_data.append((compressed << 7) | (r << 5) | w)
    bin_data.append(h)

    # pal
    bin_data.extend(snif_encode_pal(data["pal"]))

    # bnk
    banks = data["bnk"]
    mask = [x >= 0 for x in banks]
    if not mask:
        mask = 0
    mask = np.packbits(mask, bitorder="little")[0]
    bin_data.append(mask)
    for x in banks:
        if x >= 0:
            bin_data.append(x)

    # bkg
    bkg_adr = data["bkg_adr"]
    bkg_pal = data["bkg_pal"]
    bkg_data_lo = bkg_adr & 0xFF
    bkg_data_hi = (bkg_pal << 6) | (bkg_adr >> 8)
    if compressed:
        bkg_data_lo = rleinc_encode(bkg_data_lo)
        bkg_data_hi = rleinc_encode(bkg_data_hi)
    bin_data.extend(bkg_data_lo)
    bin_data.extend(bkg_data_hi)

    # spr
    spr = snif_encode_spr(data["spr_data"], w + 1, h + 1)
    bin_data.extend(spr)

    return bin_data
