from img_2_tiles import *
from rebuild import *

MAX_PIXEL_DIFF = 0
MAX_PIXEL_DIFF_SPR = 0
SPR_SIZE_W = 8
SPR_SIZE_H = 16

def tile_close_present(tile, bank):
    global MAX_PIXEL_DIFF
    a1 = np.array(tile)
    for i in range(len(bank)):
        a2 = np.array(bank[i])
        comp = a1 == a2
        nbPx = np.count_nonzero(comp)
        if TILE_SIZE*TILE_SIZE - nbPx <= MAX_PIXEL_DIFF :
            return i
    return -1


def set_pixel_diff(val):
    global MAX_PIXEL_DIFF
    MAX_PIXEL_DIFF = val

def set_spr_pixel_diff(val):
    global MAX_PIXEL_DIFF_SPR
    MAX_PIXEL_DIFF_SPR = val

def tile_present(tile, bank):
    a1 = np.array(tile)
    for i in range(len(bank)):
        a2 = np.array(bank[i])
        if np.array_equal(a1, a2):
            return i
    return -1


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
        if SPR_SIZE_W*SPR_SIZE_H - nbPx <= MAX_PIXEL_DIFF_SPR :
            return i
    return -1


def rm_exact_tiles(tileSet, tileList, tileBank):
    for i in range(len(tileSet)):
        tile = tileSet[i]
        idx = tile_present(tile, tileBank)
        if idx < 0:
            tileBank.append(tile)
            idx = len(tileBank)-1
        tileList[i] = idx
    return tileSet, tileList, tileBank


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


if __name__ == "__main__":
    imgfile = sys.argv[1]
    img = bkg_col_reduce(imgfile)
    img.save("out_pal.png")
    tileSet, tileList = bkg_img_2_tile(img)
    tileSet, tileList, tileBank = rm_closest_tiles(tileSet, tileList, [])
    print(tileList)
    write_tile_set_2_CHR("out.chr", tileBank)
    write_tile_list_2_bin("out.bin", tileList)
    rebuild_bkg_img(tileList, tileBank).save("out.png")
