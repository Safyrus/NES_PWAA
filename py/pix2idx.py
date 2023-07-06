import argparse
import numpy as np
from PIL import Image

parser = argparse.ArgumentParser()
parser.add_argument("input", type=str)
parser.add_argument("output", type=str)
args = parser.parse_args()


def img2tiles(img: Image.Image, tile_size: tuple[int, int]):
    arr = np.array(img)
    h, w = arr.shape
    print(w, h)
    tw, th = tile_size
    tiles = []
    for y in range(0, h, th):
        for x in range(0, w, tw):
            tiles.append(arr[y:y+th, x:x+tw])
    return tiles


img = Image.open(args.input).convert("L")
w, h = img.width, img.height
img = img.crop((0, 0, w - (w % 8), h - (h % 8)))
tiles = img2tiles(img, (8,8))

with open(args.output, "w") as f:
    for t in tiles:
        for y in range(8):
            line = ""
            for x in range(8):
                p = t[y, x] // 64
                line += str(p) + ","
            f.write(line+"\n")
        f.write("\n")

