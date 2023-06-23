import argparse
import cv2
import os
import glob
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument("img", type=str)
parser.add_argument("--name", required=False, type=str)
parser.add_argument("--remove", required=False, type=int)
# parser.add_argument("out", type=str)
args = parser.parse_args()

path, name = os.path.split(args.img)
name, ext = os.path.splitext(name)

if args.remove:
    rm_path = os.path.join(path, (name if not args.name else args.name) + "_*.png")
    for f in glob.glob(rm_path):
        os.remove(f)

# open image
img = cv2.imread(args.img, cv2.IMREAD_UNCHANGED)
# transform it to grayscale
img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
# turn it to black or white pixel
_, img_threashold = cv2.threshold(img_gray, 0, 255, cv2.THRESH_BINARY)

# find contours
contours, hierarchy = cv2.findContours(img_threashold, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
boxs = []
for c in contours:
    boxs.append(cv2.boundingRect(c))

boxs = sorted(boxs, key = lambda x: (x[1] + x[3], x[0] + x[2]))

# crop and save images
crops = []
for i, b in enumerate(boxs):
    # get box coordinates
    x,y,w,h = b
    # if crop big enough
    if w > 32 and h > 32:
        # get crop image
        crop = img[y:y+h, x:x+w]
        already_saved = False
        # compare crop to all previous saved crops
        for c in crops:
            if c.shape == crop.shape:
                dif = cv2.absdiff(c, crop)
                s = np.sum(dif)
                if s == 0:
                    already_saved = True
                    break
        if not already_saved:
            crops.append(crop)
            savepath = os.path.join(path, (name if not args.name else args.name) + f"_{i}" + ext)
            cv2.imwrite(savepath, crop)

