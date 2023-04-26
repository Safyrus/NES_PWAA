import sys
from PIL import Image
import math


def new_img(data_size: int, img_size: int, w: int):
    if w:
        h = data_size // w if data_size % w == 0 else (data_size // w) + 8
        img = Image.new(mode="RGB", size=(w, h))
    elif (data_size / img_size) > img_size:
        img = Image.new(mode="RGB", size=(img_size, img_size << 1))
    else:
        img = Image.new(mode="RGB", size=(img_size, img_size))
    print("img size:", img.size)
    print("nb pixel:", data_size)
    return img


def rgb(w):
    print("mode RGB")

    data_size = math.ceil(len(data)/3)
    img_size = 1 << (data_size.bit_length()//2)
    #
    img = new_img(data_size, img_size, w)

    pixels = list(img.getdata())
    idx = 0
    for i in range(len(data) // 3):
        i *= 3
        pixels[idx] = data[i+0] + (data[i+1] << 8) + (data[i+2] << 16)
        idx += 1

    if len(data) % 3 == 2:
        pixels[idx] = data[i+0] + (data[i+1] << 8)
    if len(data) % 3 == 1:
        pixels[idx] = data[i+0]

    img.putdata(pixels)
    return img


def l(w):
    print("mode grayscale")

    data_size = len(data)
    img_size = 1 << (data_size.bit_length()//2)
    #
    img = new_img(data_size, img_size, w)

    pixels = list(img.getdata())
    for i, d in enumerate(data):
        pixels[i] = d

    img.putdata(pixels)
    return img


def nes(w):
    print("mode NES")

    #
    data_size = len(data)*4
    if not w:
        w = 128
    img = new_img(data_size, None, w)

    palette = [0x000000, 0x550000, 0xAA5500, 0xFFFFFF]

    pixels = list(img.getdata())
    idx = 0
    for i in range(0, len(data), 16):
        for j in range(8):
            d1 = data[i+j] if i+j < len(data) else 0
            d2 = data[i+j+8] if i+j+8 < len(data) else 0
            for k in range(7, -1, -1):
                p = (d1 >> k) & 1
                if i+1 < len(data):
                    p += ((d2 >> k) & 1) << 1
                pixels[idx] = palette[p]
                idx += 1
            idx += w-8
        idx -= (w)*8 if ((i//16)+1) % (w // 8) != 0 else w
        idx += 8

    img.putdata(pixels)
    return img


# check args
if len(sys.argv) <= 1:
    print("args: <input binary file> [output png file] [mode:'RGB','L','NES'] [width]")
    exit(1)
# args
inputfile = sys.argv[1]
outputfile = sys.argv[2] if len(sys.argv) > 2 else "out.png"
mode = sys.argv[3] if len(sys.argv) > 3 else "L"
w = int(sys.argv[4]) if len(sys.argv) > 4 else None

#
with open(inputfile, "rb") as f:
    data = f.read()

if mode == "RGB":
    img = rgb(w)
elif mode == "L":
    img = l(w)
elif mode == "NES":
    img = nes(w)
else:
    print("unknow mode")
    exit(1)
#
img.save(outputfile)
