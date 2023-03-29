from img_col_reduce import *
import numpy as np
import sys

TILE_SIZE = 8


def img_2_tile(img):
    return bkg_img_2_tile(img)


def bkg_img_2_tile(img):
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


def chr_2_tile(data):
    tile = []
    for y in range(TILE_SIZE):
        row = []
        for x in range(TILE_SIZE):
            b1 = data[y] >> (TILE_SIZE - 1 - x) & 1
            b2 = data[y+TILE_SIZE] >> (TILE_SIZE - 1 - x) & 1
            row.append((b2 << 1) + b1)
        tile.append(row)
    return tile


def write_tile_set_2_CHR(filename, tiles):
    with open(filename, "wb") as chr:
        for t in tiles:
            chr.write(tile_2_chr(t))


def write_tile_list_2_bin(filename, tile_list):
    with open(filename, "wb") as chr:
        for t in tile_list:
            chr.write((t % 256).to_bytes(1, "big"))
        for t in tile_list:
            chr.write((t//256).to_bytes(1, "big"))


def write_spr_tile_set_2_CHR(filename, tiles):
    with open(filename, "wb") as chr:
        for t in tiles:
            t1, t2 = t[0:8, :], t[8:16, :]
            chr.write(tile_2_chr(t1))
            chr.write(tile_2_chr(t2))
