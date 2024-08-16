import sys
from glob import glob
import os

path = sys.argv[1]
out = sys.argv[2]
txt = ""

files = glob(path + '/**/*.*', recursive=True)
files.sort(key=lambda f: os.path.basename(f))

for fn in files:
    # print(fn)
    with open(fn) as f:
        txt += f.read()

with open(out, "w") as f:
    f.write(txt)
