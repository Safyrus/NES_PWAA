import sys
from PIL import Image, ImageEnhance, GifImagePlugin
import numpy as np

MAX_COLOR_BKG = 4
MAX_COLOR_CHR = 7+1
CONTRAST_BKG = 2


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
    return img.convert("L")


def char_col_reduce(imgfile):
    with Image.open(imgfile) as img:
        img = img.convert("L")
    img = img.quantize(MAX_COLOR_CHR, method=Image.FASTOCTREE)
    return img.convert("L")


if __name__ == "__main__":
    imgfile = sys.argv[1]
    bkg_col_reduce(imgfile).save("out.bmp")
