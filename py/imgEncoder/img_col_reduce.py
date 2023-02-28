import sys
from PIL import Image, ImageEnhance
import numpy as np

MAX_COLOR_BKG = 4
MAX_COLOR_CHR = 7+1
CONTRAST_BKG = 2

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
    [-1,  -1,  -1],
    [-1,  -1,  -1],
    [0,   0,   0],

    [254, 255, 255],
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
    [-1,  -1,  -1],
    [-1,  -1,  -1],
    [-1,  -1,  -1],

    [254, 255, 255],
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
    [-1,  -1,  -1],
    [-1,  -1,  -1],

    [160, 160, 160],
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
    [-1,  -1,  -1],
    [-1,  -1,  -1],

]


def closest_color(pal, color):
    pal = np.array(pal)
    color = np.array(color)

    dist = np.sqrt(np.sum((pal-color)**2, axis=1))
    idx = np.where(dist == np.amin(dist))

    return idx[0][0]


def closest_nes_pal(img, size):
    img_pal = img.getpalette()
    pal = []
    size = min(size*3, len(img_pal))
    for i in range(0, size, 3):
        col = closest_color(NES_PAL, img_pal[i:i+3])
        pal.append(col)
    return pal


def bkg_col_reduce_dither(imgfile):
    with Image.open(imgfile) as img:
        img = img.convert("RGB")
    enhancer = ImageEnhance.Contrast(img)
    img_ctrst = enhancer.enhance(CONTRAST_BKG)
    img_pal = img_ctrst.quantize(MAX_COLOR_BKG, method=Image.MAXCOVERAGE)
    img = img.quantize(MAX_COLOR_BKG, palette=img_pal)
    return img


def bkg_col_reduce(imgfile):
    with Image.open(imgfile) as img:
        img = img.convert("RGB")
    img = img.quantize(MAX_COLOR_BKG, method=Image.MEDIANCUT, kmeans=1)
    return img


def bkg_col_reduce_2(imgfile):
    with Image.open(imgfile) as img:
        img = img.convert("RGB")
    img = img.quantize(MAX_COLOR_BKG, method=Image.MEDIANCUT, kmeans=1)
    pal = closest_nes_pal(img, MAX_COLOR_BKG)
    return img.convert("L"), pal


def char_col_reduce(imgfile):
    with Image.open(imgfile) as img:
        img_1 = img.convert("RGB")
        img_2 = img.convert("L")
    img_1 = ImageEnhance.Color(img_1).enhance(2)
    img_1 = img_1.quantize(MAX_COLOR_CHR, method=Image.FASTOCTREE)
    pal = closest_nes_pal(img_1, MAX_COLOR_CHR)
    img_2 = img_2.quantize(MAX_COLOR_CHR, method=Image.FASTOCTREE)
    return img_2.convert("L"), pal


if __name__ == "__main__":
    imgfile = sys.argv[1]
    with Image.open(imgfile) as img:
        img_1 = img.convert("RGB")
        img_2 = img.convert("L")

    img_1.save("img_1_0.png")
    img_2.save("img_2_0.png")

    img_1 = ImageEnhance.Color(img_1).enhance(2)
    img_1.save("img_1_1.png")
    img_1 = img_1.quantize(MAX_COLOR_CHR, method=Image.FASTOCTREE)
    img_1.save("img_1_2.png")

    pal = closest_nes_pal(img_1, MAX_COLOR_CHR)
    print(pal)
    # pal.sort()
    # if 15 in pal:
    #     i = pal.index(15)
    #     pal[i], pal[0] = pal[0], pal[i]
    pal_rgb = []
    for i in pal:
        pal_rgb.extend(NES_PAL[i])

    img_2 = img_2.quantize(MAX_COLOR_CHR, method=Image.FASTOCTREE)
    img_2.save("img_2_1.png")
    print(img_2.getpalette()[:8*3])
    img_2.putpalette(pal_rgb)
    img_2.save("out.png")
