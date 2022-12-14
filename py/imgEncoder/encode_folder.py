import sys
import os
import re
from rle_inc import *

path = sys.argv[1]
files = os.listdir(path)

tile_bank = []
i = 0
for fn in files:
    is_img = re.search(r"\.png$", fn)
    if not is_img:
        print("not image, ignoring ", fn, i, "/", len(files))
        i += 1
        continue

    print("encode:", fn, i, "/", len(files))
    fullpath = path + "/" + fn
    img = bkg_col_reduce(fullpath)
    tile_set, tile_list = bkg_img_2_tile(img)
    tile_set, tile_list, tile_bank = rm_closest_tiles(tile_set, tile_list, tile_bank)
    data = []
    for t in tile_list:
        data.append(t%256)
    for t in tile_list:
        data.append(t//256)
    tile_list = rleinc_encode(data)
    with open(fullpath[:-4] + ".bin", "wb") as chr:
        for t in tile_list:
            chr.write(t.to_bytes(1, "big"))
    i += 1

print("saving tiles")
write_tile_set_2_CHR("bank.chr", tile_bank)


print("done")
