import argparse
import os
import glob
import numpy as np
from PIL import Image
from tqdm import tqdm

def main(args):
    palette_in = [
        (0,0,0,255),
    ]

    palette_out = [
        (1,1,1,255),
    ]

    # find all png
    files = glob.glob(args.folder + '/**/*.png', recursive=True)
    print("number of png found:",len(files))

    #
    for file in tqdm(files, desc=f"replace colors"):
        # open image
        img = Image.open(file).convert("RGBA")
        # replace pixels
        for y in range(img.height):
            for x in range(img.width):
                p = img.getpixel((x, y))
                if p in palette_in:
                    idx = palette_in.index(p)
                    img.putpixel((x,y), palette_out[idx])
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
