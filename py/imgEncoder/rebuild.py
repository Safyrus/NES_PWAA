from img_2_tiles import TILE_SIZE
from PIL import Image
import numpy as np
import rle_inc

SPR_BANK_PAGE_SIZE = 256

def draw_tile(tile, img, idx):
    offsetX = (idx % (img.width // TILE_SIZE)) * TILE_SIZE
    offsetY = (idx // (img.width // TILE_SIZE)) * TILE_SIZE
    pixels = img.load()
    for y in range(len(tile)):
        row = tile[y]
        for x in range(len(row)):
            px = tile[y][x]
            pixels[offsetX + x, offsetY + y] = int(px)
    return img


def draw_sprite(spr, img, offsetX, offsetY):
    pixels = img.load()
    for y in range(len(spr)):
        row = spr[y]
        for x in range(len(row)):
            px = spr[y][x]
            if px:
                pixels[offsetX + x, offsetY + y] = int(px)
    return img


def rebuild_bkg_img(tileList, tileBank, nb_color=4):
    if nb_color == 4:
        pal = (0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255)
    else:
        pal = [i//3 for i in range(nb_color*3)]

    img = Image.new("P", (256, 192))
    img.putpalette(pal)
    for i in range(len(tileList)):
        t = tileList[i]
        img = draw_tile(tileBank[t], img, i)
    return img


def rebuild_frame_img(tile_map, spr_map, tile_bank, spr_bank, nb_color=13):
    # decode sprite map
    spr_info = spr_map[:4]
    spr_map = rle_inc.rleinc_decode(spr_map[4:])
    # decode tile map and palette map
    decode = rle_inc.rleinc_decode(tile_map)
    pal_map = []
    tile_map = []
    l = len(decode) // 2
    for i in range(0, l):
        lo = decode[i]
        hi = (decode[i+l] & 0x3F) << 8
        tile_map.append(lo | hi)
        pal_map.append(decode[i+l] >> 6)

    # create image
    pal = [i//3 for i in range(nb_color*3)]
    img = Image.new("P", (256, 192))
    img.putpalette(pal)

    # rebuild color palette
    palettes = [
        [0, 1, 2, 3],
        [0, 4, 5, 6],
        [0, 7, 8, 9],
        [0, 10, 11, 12],
    ]

    # rebuild background
    for i in range(len(tile_map)):
        t = tile_map[i]
        p = pal_map[i]
        tile = tile_bank[t]
        for j in range(1, 4):
            tile = np.where(tile == j, palettes[p][j], tile)
        img = draw_tile(tile, img, i)

    # rebuild sprites
    page = spr_info[1] * SPR_BANK_PAGE_SIZE
    for i in range(len(spr_map)):
        s = spr_map[i]
        tile = spr_bank[s + page]
        for j in range(1, 4):
            tile = np.where(tile == j, palettes[3][j], tile)
        x = spr_info[2] + ((i % spr_info[0]) * 8)
        y = spr_info[3] + ((i // spr_info[0]) * 16)
        img = draw_sprite(tile, img, x, y)

    return img
