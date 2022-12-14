from img_2_tiles import *
from rebuild import *

MAX_PIXEL_DIFF = 0

def tile_close_present(tile, bank):
    a1 = np.array(tile)
    for i in range(len(bank)):
        a2 = np.array(bank[i])
        comp = a1 == a2
        nbPx = np.count_nonzero(comp)
        if TILE_SIZE*TILE_SIZE - nbPx <= MAX_PIXEL_DIFF :
            return i
    return -1


def tile_present(tile, bank):
    a1 = np.array(tile)
    for i in range(len(bank)):
        a2 = np.array(bank[i])
        if np.array_equal(a1, a2):
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
