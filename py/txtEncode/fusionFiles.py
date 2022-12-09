import sys
import os

path = sys.argv[1]
out = sys.argv[2]
files = os.listdir(path)
txt = ""

for fn in files:
    with open(path+"/"+fn) as f:
        txt += f.read()

with open(out, "w") as f:
    f.write(txt)
