import sys
from PIL import Image, ImageEnhance
import numpy as np

MAX_COLOR_BKG = 4
MAX_COLOR_CHR = 6+1
CONTRAST_BKG = 1
SATURATION_CHR = 1
CHR_METHOD = Image.MEDIANCUT
BKG_METHOD = Image.MEDIANCUT

NES_PAL = [
    [82,  82,  82],
    [1,  26,  81],
    [15,  15, 101],
    [35,   6,  99],
    [54,   3,  75],
    [64,   4,  38],
    [63,   9,   4],
    [50,  19,   0],
    [31,  32,   0],
    [11,  42,   0],
    [0,  47,   0],
    [0,  46,  10],
    [0,  38,  45],
    [-255, -255, 255],
    [-255, -255, 255],
    [1,   1,   1],

    [160, 160, 160],
    [30,  74, 157],
    [56,  55, 188],
    [88,  40, 184],
    [117,  33, 148],
    [132,  35,  92],
    [130,  46,  36],
    [111,  63,   0],
    [81,  82,   0],
    [49,  99,   0],
    [26, 107,   5],
    [14, 105,  46],
    [16,  92, 104],
    [-255, -255, 255],
    [-255, -255, 255],
    [-255, -255, 255],

    [-1,  -1,  -1],
    [105, 158, 252],
    [137, 135, 255],
    [174, 118, 255],
    [206, 109, 241],
    [224, 112, 178],
    [222, 124, 112],
    [200, 145,  62],
    [166, 167,  37],
    [129, 186,  40],
    [99, 196,  70],
    [84, 193, 125],
    [86, 179, 192],
    [60,  60,  60],
    [-255, -255, 255],
    [-255, -255, 255],

    [254, 255, 255],
    [190, 214, 253],
    [204, 204, 255],
    [221, 196, 255],
    [234, 192, 249],
    [242, 193, 223],
    [241, 199, 194],
    [232, 208, 170],
    [217, 218, 157],
    [201, 226, 158],
    [188, 230, 174],
    [180, 229, 199],
    [181, 223, 228],
    [169, 169, 169],
    [-255, -255, 255],
    [-255, -255, 255],

]

NES_PAL_NAM = [
    "DARK GRAY",
    "DARKEST BLUE",
    "DARKEST SLATEBLUE",
    "DARKEST MAGENTA",
    "DARKEST PINK",
    "DARKEST SALMON",
    "DARKEST RED",
    "DARKEST ORANGE",
    "DARKEST YELLOW",
    "DARKEST OLIVE",
    "DARKEST GREEN",
    "DARKEST CYAN",
    "DARKEST LIGHT BLUE",
    "BLACKER THAN BLACK",
    "BLACK",
    "BLACK",

    "GRAY",
    "DARK BLUE",
    "DARK SLATEBLUE",
    "DARK MAGENTA",
    "DARK PINK",
    "DARK SALMON",
    "DARK RED",
    "DARK ORANGE",
    "DARK YELLOW",
    "DARK OLIVE",
    "DARK GREEN",
    "DARK CYAN",
    "DARK LIGHT BLUE",
    "BLACK",
    "BLACK",
    "BLACK",

    "WHITE",
    "BLUE",
    "SLATEBLUE",
    "MAGENTA",
    "PINK",
    "SALMON",
    "RED",
    "ORANGE",
    "YELLOW",
    "OLIVE",
    "GREEN",
    "CYAN",
    "LIGHT BLUE",
    "DARKEST GRAY",
    "BLACK",
    "BLACK",

    "WHITE",
    "LIGHT BLUE",
    "LIGHT SLATEBLUE",
    "LIGHT MAGENTA",
    "LIGHT PINK",
    "LIGHT SALMON",
    "LIGHT RED",
    "LIGHT ORANGE",
    "LIGHT YELLOW",
    "LIGHT OLIVE",
    "LIGHT GREEN",
    "LIGHT CYAN",
    "LIGHT LIGHT BLUE",
    "LIGHT GRAY",
    "BLACK",
    "BLACK",
]


def closest_color(pal, color):
    pal = np.array(pal)
    color = np.array(color)

    dist = np.sqrt(np.sum((pal-color)**2, axis=1))
    idx = np.where(dist == np.amin(dist))

    return idx[0][0]


def closest_nes_pal(img, size):
    img_pal_idx = img.getcolors()
    img_pal_idx = [v for _, v in img_pal_idx]  # remove color count from list

    img_pal = img.getpalette()
    pal = []
    for i in img_pal_idx:
        i *= 3
        col = closest_color(NES_PAL, img_pal[i:i+3])
        pal.append(col)
    pad = max(0, size-len(pal))
    pal.extend([15 for _ in range(pad)])
    return pal


def sort_nes_pal(pal):
    pal.sort()
    lo_idx = 0
    hi_idx = len(pal)
    if 0x0F in pal:
        i = pal.index(0x0F)
        pal[lo_idx], pal[i] = pal[i], pal[lo_idx]
        lo_idx += 1
    if 0x2D in pal:
        i = pal.index(0x2D)
        pal[lo_idx], pal[i] = pal[i], pal[lo_idx]
        lo_idx += 1
    if 0x30 in pal:
        i = pal.index(0x30)
        hi_idx -= 1
        pal[hi_idx], pal[i] = pal[i], pal[hi_idx]
    if lo_idx or hi_idx != len(pal):
        pal[lo_idx:hi_idx].sort()
    return pal


def bkg_col_reduce(imgfile):
    with Image.open(imgfile) as img:
        img = img.convert("RGB")
    img = img.quantize(MAX_COLOR_BKG, method=BKG_METHOD, kmeans=1)
    pal = closest_nes_pal(img, MAX_COLOR_BKG)
    # pal = sort_nes_pal(pal)

    # convert to gray scale
    # and reorder palette (because of conversion)
    col = img.getcolors()
    img = img.convert('L')
    new_col = img.getcolors()
    new_pal = []
    for n,_ in new_col:
        idx = -1
        for m,i in col:
            if m == n:
                idx = i
                break
        new_pal.append(pal[idx])
    pal = new_pal

    return img, pal


def char_col_reduce(imgfile):
    with Image.open(imgfile) as img:
        # Replace (0,0,0) with (1,1,1)
        # because converting to RGB will change alpha to (0,0,0)
        # merging transparant with the actual black
        img = img.convert("RGBA")
        pixdata = img.load()
        for y in range(img.size[1]):
            for x in range(img.size[0]):
                if pixdata[x, y] == (0, 0, 0, 255):
                    pixdata[x, y] = (1, 1, 1, 255)
        # convert to RGB
        img = img.convert("RGB")
    img = ImageEnhance.Color(img).enhance(SATURATION_CHR)
    img = img.quantize(MAX_COLOR_CHR+1, method=CHR_METHOD)
    pal = closest_nes_pal(img, MAX_COLOR_CHR+1)

    # convert to gray scale
    # and reorder palette (because of conversion)
    col = img.getcolors()
    img = img.convert('L')
    new_col = img.getcolors()
    new_pal = []
    for n,_ in new_col:
        idx = -1
        for m,i in col:
            if m == n:
                idx = i
                break
        new_pal.append(pal[idx])
    pal = new_pal

    return img, pal
