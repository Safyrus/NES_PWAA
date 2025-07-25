import argparse
from glob import glob
import os
from PIL import Image
from tqdm import tqdm
import numpy as np

def gif2png(gif : Image.Image, FPS=60, savepath="", MAX_FRAME=85) -> list[int]:
    n = 0
    for i in range(gif.n_frames):
        try:
            gif.seek(i) # set gif to frame i
            duration = gif.info["duration"]
            duration = round(duration/(1000/FPS)) # millisecond -> frame count
            if savepath:
                while duration > 0:
                    outpath = os.path.splitext(savepath)[0] + f"_i{n}t{duration if duration < 256 else 255}.png"
                    outpath = os.path.join(args.output, outpath)
                    os.makedirs(os.path.dirname(outpath), exist_ok=True)
                    gif.save(outpath)
                    duration -= 255
                    n += 1
        # because some gif are not well encoded
        except Exception as e:
            print(e)
            print("error with frame", i)
    if n >= MAX_FRAME:
        print(f"\033[31mERROR: Too Many frames! {n} frames found, should be below {MAX_FRAME}.\033[0m")


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
