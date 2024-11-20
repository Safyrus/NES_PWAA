import argparse
from glob import glob
import os
from PIL import Image
from tqdm import tqdm
import numpy as np

def gif2png(gif : Image.Image, FPS=60, savepath="") -> list[int]:
    for i in range(gif.n_frames):
        try:
            gif.seek(i) # set gif to frame i
            duration = gif.info["duration"]
            duration = round(duration/(1000/FPS)) # millisecond -> frame count
            if savepath:
                outpath = os.path.splitext(savepath)[0] + f"_i{i}t{duration}.png"
                outpath = os.path.join(args.output, outpath)
                os.makedirs(os.path.dirname(outpath), exist_ok=True)
                gif.save(outpath)
                gif.save("tmp.png")
        # because some gif are not well encoded
        except Exception as e:
            print(e)
            print("error with frame", i)


parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input_folder", dest="input", type=str)
parser.add_argument("-o", "--output_folder", dest = "output", default="out_gif", type=str)
args = parser.parse_args()

print("searching", args.input)
files = glob('**/*.gif', root_dir=args.input, recursive=True)
print(files)

for file in tqdm(files):
    gif = Image.open(os.path.join(args.input, file))
    gif2png(gif, savepath=file)
