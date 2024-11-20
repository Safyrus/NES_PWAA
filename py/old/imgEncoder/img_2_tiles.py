from img_col_reduce import *
import numpy as np

TILE_SIZE = 8


def img_2_tile(img : Image.Image):
    arr = np.array(img)
    w, h = arr.shape[0], arr.shape[1]
    tiles = [arr[x:x+TILE_SIZE, y:y+TILE_SIZE]
             for x in range(0, w, TILE_SIZE) for y in range(0, h, TILE_SIZE)]
    list = [i for i in range(len(tiles))]
    return tiles, list


def tile_2_chr(tile):
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
