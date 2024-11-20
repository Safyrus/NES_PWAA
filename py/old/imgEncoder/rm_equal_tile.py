from img_2_tiles import *

SPR_BANK_PAGE_SIZE = 256
MAX_PIXEL_DIFF = 0
MAX_PIXEL_DIFF_SPR = 0
SPR_SIZE_W = 8
SPR_SIZE_H = 16
MAX_SPRITE_COUNT = 63


def tile_close_present(tile, bank):
    global MAX_PIXEL_DIFF
    for i in range(len(bank)):
        s = 0
        for y in range(TILE_SIZE):
            for x in range(TILE_SIZE):
                if tile[y][x] != bank[i][y][x]:
                    s += 1
                    if s > MAX_PIXEL_DIFF:
                        break
            else:
                continue
            break
        if s <= MAX_PIXEL_DIFF:
            return i
    return -1


def set_pixel_diff(val):
    global MAX_PIXEL_DIFF
    MAX_PIXEL_DIFF = val


def set_spr_pixel_diff(val):
    global MAX_PIXEL_DIFF_SPR
    MAX_PIXEL_DIFF_SPR = val


def spr_tile_close_present(tile, bank):
    global MAX_PIXEL_DIFF_SPR
    a1 = np.array(tile)
    page = len(bank) // SPR_BANK_PAGE_SIZE
    start = page * SPR_BANK_PAGE_SIZE
    end = min(len(bank), start + SPR_BANK_PAGE_SIZE)
    #
    if np.count_nonzero(a1) < MAX_PIXEL_DIFF_SPR:
        return start
    #
    for i in range(start, end):
        a2 = np.array(bank[i])
        comp = a1 == a2
        nbPx = np.count_nonzero(comp)
        if SPR_SIZE_W*SPR_SIZE_H - nbPx <= MAX_PIXEL_DIFF_SPR:
            return i
    return -1


def rm_closest_tiles(tileSet, tileList, tileBank):
    for i in range(len(tileSet)):
        tile = tileSet[i]
        idx = tile_close_present(tile, tileBank)
        if idx < 0:
            tileBank.append(tile)
            idx = len(tileBank)-1
        tileList[i] = idx
    return tileSet, tileList, tileBank


def rm_closest_spr_tiles(tileSet, tileList, tileBank):

    if len(tileSet) > MAX_SPRITE_COUNT:
        tile2keep = []
        i = 0
        tmp = []
        for t in tileList:
            tmp.append(t)
        while len(tile2keep) < MAX_SPRITE_COUNT and i < len(tileSet):
            if np.sum(tileSet[i]) > MAX_PIXEL_DIFF_SPR:
                tile2keep.append(tmp[i])
            i += 1
        for i in range(len(tileSet)):
            if i not in tile2keep:
                tileSet[i] = tileBank[0].copy()

    # remove same tiles by supposing enought space in page
    tmpBank = tileBank.copy()
    for i in range(len(tileSet)):
        tile = tileSet[i]
        idx = spr_tile_close_present(tile, tmpBank)
        if idx < 0:
            tmpBank.append(tile)
            idx = len(tmpBank)-1 % SPR_BANK_PAGE_SIZE
        tileList[i] = idx

    # vars
    page_bnk_before = len(tileBank) // SPR_BANK_PAGE_SIZE
    page_bnk_after = len(tmpBank) // SPR_BANK_PAGE_SIZE
    page_size_remain = SPR_BANK_PAGE_SIZE - len(tileBank) % SPR_BANK_PAGE_SIZE

    # return if new tile are in same page
    if page_bnk_after == page_bnk_before:
        return tileSet, tileList, tmpBank

    # Pad with empty tiles
    empty_tile = np.zeros(tileSet[0].shape, dtype=int)
    for _ in range(page_size_remain):
        tileBank.append(empty_tile)
    tileBank.append(empty_tile)

    # redo removing tiles with new alignement
    for i in range(len(tileSet)):
        tile = tileSet[i]
        idx = spr_tile_close_present(tile, tileBank)
        if idx < 0:
            tileBank.append(tile)
            idx = len(tileBank)-1 % SPR_BANK_PAGE_SIZE
        tileList[i] = idx

    return tileSet, tileList, tileBank
