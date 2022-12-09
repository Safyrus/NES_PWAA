from imgPalReduce import *
import numpy as np
import sys

TILE_SIZE = 8


def bkgImg2tile(img):
    arr = np.array(img)
    w, h = arr.shape[0], arr.shape[1]
    tiles = [arr[x:x+TILE_SIZE, y:y+TILE_SIZE]
             for x in range(0, w, TILE_SIZE) for y in range(0, h, TILE_SIZE)]
    list = [i for i in range(len(tiles))]
    return tiles, list


def tile2chr(tile):
    chr = []
    #
    for y in range(TILE_SIZE):
        b = 0
        for x in range(TILE_SIZE):
            b |= (tile[y][x] & 1) << (TILE_SIZE - 1 - x)
        chr.append(b)
    #
    for y in range(TILE_SIZE):
        b = 0
        for x in range(TILE_SIZE):
            b |= ((tile[y][x] & 2) >> 1) << (TILE_SIZE - 1 - x)
        chr.append(b)
    return bytes(chr)


def chr2tile(data):
    tile = []
    for y in range(TILE_SIZE):
        row = []
        for x in range(TILE_SIZE):
            b1 = data[y] >> (TILE_SIZE - 1 - x) & 1
            b2 = data[y+TILE_SIZE] >> (TILE_SIZE - 1 - x) & 1
            row.append((b2 << 1) + b1)
        tile.append(row)
    return tile


def writeTileSet2CHR(filename, tiles):
    with open(filename, "wb") as chr:
        for t in tiles:
            chr.write(tile2chr(t))


def writeTileList2Bin(filename, tileList):
    with open(filename, "wb") as chr:
        for t in tileList:
            chr.write((t % 256).to_bytes(1, "big"))
        for t in tileList:
            chr.write((t//256).to_bytes(1, "big"))


if __name__ == "__main__":
    imgfile = sys.argv[1]
    tiles, list = bkgImg2tile(bkgPalReduce(imgfile))
    writeTileSet2CHR("out.chr", tiles)
    writeTileList2Bin("out.bin", list)
