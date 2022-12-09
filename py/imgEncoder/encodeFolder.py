import sys
import os
import re
from rle_inc import *

path = sys.argv[1]
files = os.listdir(path)

tileBank = []
i = 0
for fn in files:
    isImg = re.search(r"\.png$", fn)
    if not isImg:
        print("not image, ignoring ", fn, i, "/", len(files))
        i += 1
        continue

    print("encode:", fn, i, "/", len(files))
    fullpath = path + "/" + fn
    img = bkgPalReduce(fullpath)
    tileSet, tileList = bkgImg2tile(img)
    tileSet, tileList, tileBank = rmClosestTiles(tileSet, tileList, tileBank)
    data = []
    for t in tileList:
        data.append(t%256)
    for t in tileList:
        data.append(t//256)
    tileList = rleinc_encode(data)
    with open(fullpath[:-4] + ".bin", "wb") as chr:
        for t in tileList:
            chr.write(t.to_bytes(1, "big"))
    i += 1

print("saving tiles")
writeTileSet2CHR("bank.chr", tileBank)

print("done")
