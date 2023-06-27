import argparse
import os
import glob
import numpy as np
from PIL import Image
from tqdm import tqdm

def replace_background(img, new_col=(0,0,0,0)) -> Image.Image:
    img = img.convert("RGBA")
    # get sample points
    w,h = img.size
    points = [
        img.getpixel((0   , 0)), # top left
        img.getpixel((w//2, 0)), # top
        img.getpixel((w-1 , 0)), # top right
        img.getpixel((0   , h//2)), # mid left
        img.getpixel((w//2, h//2)), # mid
        img.getpixel((w-1 , h//2)), # mid right
        img.getpixel((0   , h-1)), # bot left
        img.getpixel((w//2, h-1)), # bot
        img.getpixel((w-1 , h-1)), # bot right
    ]
    # find background color
    background_color = tuple(np.median(points, axis=0))
    # replace pixels
    img = np.array(img)
    for i in range(len(img)):
        for j in range(len(img[i])):
            if tuple(img[i,j,0:4]) == background_color:
                img[i,j,0:4] = new_col
    return Image.fromarray(img)


def main(args):
    # find all png
    files = glob.glob(args.folder + '/**/*.png', recursive=True)
    print("number of png found:",len(files))
    #
    for file in tqdm(files, desc=f"add transparency"):
        # open image
        img = Image.open(file)
        # remove background
        img = replace_background(img)
        # save image
        path = os.path.relpath(file, args.folder)
        path = os.path.join(args.out, path)
        dir = os.path.split(path)[0]
        os.makedirs(dir, exist_ok=True)
        img.save(path)

if __name__ =="__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("folder", type=str)
    parser.add_argument("--out", default="out_rgba", type=str)
    args = parser.parse_args()
    main(args)
