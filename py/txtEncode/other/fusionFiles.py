import sys
from glob import glob
import os

path = sys.argv[1]
out = sys.argv[2]
verbose = False
txt = ""

files = glob(path + '/**/*.*', recursive=True)
files.sort(key=lambda f: os.path.basename(f))

for fn in files:
    if verbose:
        print(fn)
    with open(fn, encoding="utf-8") as f:
        txt += f.read()

with open(out, "w", encoding="utf-8") as f:
    f.write(txt)
