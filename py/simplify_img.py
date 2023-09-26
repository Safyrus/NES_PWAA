import argparse
import glob
import os
import numpy as np
from tqdm import tqdm
from PIL import Image

from scipy import ndimage

def compute_tile_scores(tiles):
    l = len(tiles)
    # init empty array
    scores = np.zeros(l, dtype=np.float32)
    # compute scores
    for i in tqdm(range(l), desc="compute scores"):
        s = np.sum(np.abs(tiles[i] - tiles[:, np.newaxis]))
        e = sobel_score(tiles[i])
        s = (len(tiles)*256) / s if s > 0 else 0
        e = (256*64) / e if e > 0 else 0
        scores[i] = s + e
    return scores


def sobel_score(tile):
    sobel_h = ndimage.sobel(tile, 0)
    sobel_v = ndimage.sobel(tile, 1)
    magnitude = np.sqrt(sobel_h**2 + sobel_v**2)
    if np.max(magnitude) == 0:
        magnitude = 0
    else:
        magnitude *= 256 / np.max(magnitude)
        magnitude = int(np.sum(magnitude))
    return magnitude


def replace_tiles(image: Image.Image, MAX_TILE=256):

    # convert image to palette orderer by 'luminosity'
    image.apply_transparency()
    nb_color = len(image.getcolors())
    image = image.convert("P")

    res_img = image.copy()
    tiles = {}

    # cut images into tiles
    TILE_SIZE = 8
    img = np.array(image)
    #
    w, h = img.shape[0], img.shape[1]
    idx_img = []
    #
    img_tiles = [img[x:x+TILE_SIZE, y:y+TILE_SIZE] for x in range(0, w, TILE_SIZE) for y in range(0, h, TILE_SIZE)]
    #
    for t in img_tiles:
        h = hash(bytes(t))
        tiles[h] = t
        idx_img.append(h)
    #
    map = np.array(idx_img)
    print("number of tile:", len(tiles))

    # replace maps tiles hash by index
    for i, k in tqdm(enumerate(tiles.keys()), desc="map to index", total=len(tiles)):
        map[map == k] = i
    # tiles to numpy array
    tiles = np.array([x for x in tiles.values()], dtype=int)

    # find difference between tiles
    dif = compute_tile_scores(tiles)

    #
    min_dif = sorted(dif)[min(len(dif), MAX_TILE)-1]
    #
    argsorted = np.argsort(dif)
    #
    tile_dif_pairs = [(dif[i], tiles[i]) for i in range(len(tiles))]
    sorted_tiles = sorted(tile_dif_pairs, key=lambda x:x[0])
    sorted_tiles = [x[1] for x in sorted_tiles]

    # replace tiles
    map = np.multiply(map, -1)
    for i in tqdm(range(len(tiles)), desc="replace tiles"):
        #
        d = np.abs(tiles[i] - tiles[:, np.newaxis])
        d = np.sum(np.sum(d, axis=-1), axis=-1)
        #
        m = np.max(d)+1
        for j in range(len(dif)):
            if dif[j] > min_dif:
                d[j] = m
        #
        if dif[i] > min_dif:
            d[d == 0] = np.max(d) + 1
        #
        idx = np.argmin(d)
        true_idx = np.argwhere(argsorted==idx)[0][0]
        #
        map[(map*-1) == i] = true_idx

    # convert tiles to CHR
    tiles = []
    for idx in range(0, min(len(sorted_tiles), MAX_TILE)):
        tiles.append(sorted_tiles[idx])

    for i, m in enumerate(map):
        t = Image.fromarray(tiles[m])
        x = (i * TILE_SIZE) % res_img.width
        y = ((i * TILE_SIZE) // res_img.width) * TILE_SIZE
        res_img.paste(t, (x,y))

    return res_img


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("i", type=str)
    parser.add_argument("o", type=str)
    parser.add_argument("-max_tile", required=False, type=int, default=256)
    args = parser.parse_args()

    img = Image.open(args.i)
    new_img = replace_tiles(img, args.max_tile)
    new_img.save(args.o)
