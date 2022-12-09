import sys
from PIL import Image, ImageEnhance

MAX_COLOR_BKG = 4
MAX_COLOR_CHR = 7
CONTRAST_BKG = 2


def bkgPalReduceDither(imgfile):
    with Image.open(imgfile) as img:
        img = img.convert("RGB")
    enhancer = ImageEnhance.Contrast(img)
    img_ctrst = enhancer.enhance(CONTRAST_BKG)
    img_pal = img_ctrst.quantize(MAX_COLOR_BKG, method=Image.MAXCOVERAGE)
    img = img.quantize(MAX_COLOR_BKG, palette=img_pal)
    return img


def bkgPalReduce(imgfile):
    with Image.open(imgfile) as img:
        img = img.convert("RGB")
    img = img.quantize(MAX_COLOR_BKG, method=Image.MEDIANCUT, kmeans=1)
    pal = img.getpalette()
    return img


def charPalReduce(imgfile):
    with Image.open(imgfile) as img:
        img = img.convert("RGB")
    img = img.quantize(MAX_COLOR_CHR, method=Image.MAXCOVERAGE, kmeans=1)
    return img


if __name__ == "__main__":
    imgfile = sys.argv[1]
    bkgPalReduce(imgfile).save("out.bmp")
