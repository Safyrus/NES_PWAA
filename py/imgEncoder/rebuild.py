from img2tiles import TILE_SIZE
from PIL import Image


def drawTile(tile, img, idx):
    offsetX = (idx % (img.width // TILE_SIZE)) * TILE_SIZE
    offsetY = (idx // (img.width // TILE_SIZE)) * TILE_SIZE
    pixels = img.load()
    for y in range(len(tile)):
        row = tile[y]
        for x in range(len(row)):
            px = tile[y][x]
            pixels[offsetX + x, offsetY + y] = int(px)
    return img


def rebuildBkgImg(tileList, tileBank, nb_color=4):
    if nb_color == 4:
        pal = (0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255)
    else:
        pal = [i//3 for i in range(nb_color*3)]

    img = Image.new("P", (256, 192))
    img.putpalette(pal)
    for i in range(len(tileList)):
        t = tileList[i]
        img = drawTile(tileBank[t], img, i)
    return img

