from img2tiles import *
from rebuild import *

MAX_PIXEL_DIFF = 2

def tileClosePresent(tile, bank):
    a1 = np.array(tile)
    for i in range(len(bank)):
        a2 = np.array(bank[i])
        comp = a1 == a2
        nbPx = np.count_nonzero(comp)
        if TILE_SIZE*TILE_SIZE - nbPx <= MAX_PIXEL_DIFF :
            return i
    return -1


def tilePresent(tile, bank):
    a1 = np.array(tile)
    for i in range(len(bank)):
        a2 = np.array(bank[i])
        if np.array_equal(a1, a2):
            return i
    return -1


def rmExactTiles(tileSet, tileList, tileBank):
    for i in range(len(tileSet)):
        tile = tileSet[i]
        idx = tilePresent(tile, tileBank)
        if idx < 0:
            tileBank.append(tile)
            idx = len(tileBank)-1
        tileList[i] = idx
    return tileSet, tileList, tileBank


def rmClosestTiles(tileSet, tileList, tileBank):
    for i in range(len(tileSet)):
        tile = tileSet[i]
        idx = tileClosePresent(tile, tileBank)
        if idx < 0:
            tileBank.append(tile)
            idx = len(tileBank)-1
        tileList[i] = idx
    return tileSet, tileList, tileBank


if __name__ == "__main__":
    imgfile = sys.argv[1]
    img = bkgPalReduce(imgfile)
    img.save("out_pal.png")
    tileSet, tileList = bkgImg2tile(img)
    tileSet, tileList, tileBank = rmClosestTiles(tileSet, tileList, [])
    print(tileList)
    writeTileSet2CHR("out.chr", tileBank)
    writeTileList2Bin("out.bin", tileList)
    rebuildBkgImg(tileList, tileBank).save("out.png")
