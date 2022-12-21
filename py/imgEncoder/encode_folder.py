import glob
import sys
from rle_inc import *

# get path
path = sys.argv[1]
files = glob.glob(path + '/**/*.png', recursive=True)
print(len(files), "image files found")
print("MAX_PIXEL_DIFF:", MAX_PIXEL_DIFF)

# init tile bank
tile_bank = [
    np.full((TILE_SIZE, TILE_SIZE), 0),
    np.full((TILE_SIZE, TILE_SIZE), 1),
    np.full((TILE_SIZE, TILE_SIZE), 2),
    np.full((TILE_SIZE, TILE_SIZE), 3),
]

# main loop
toomanytile = False
i = 0
for fn in files:
    print("encode:", fn, i, "/", len(files), end="", flush=True)
    img = bkg_col_reduce(fn)
    tile_set, tile_list = bkg_img_2_tile(img)
    tile_set, tile_list, tile_bank = rm_closest_tiles(tile_set, tile_list, tile_bank)

    print(" ", "unique tile:", len(tile_bank))
    if not toomanytile and len(tile_bank) > 256*256:
        print("[WARNING]: TOO MANY TILES TO FIT INTO 1MB")
        toomanytile = True

    # refactor data to be more compressable
    data = []
    for t in tile_list:
        data.append(t%256)
    for t in tile_list:
        data.append(t//256)

    # encode tile map
    tile_list = rleinc_encode(data)
    # write tile map
    with open(fn[:-4] + ".bin", "wb") as chr:
        for t in tile_list:
            chr.write(t.to_bytes(1, "big"))
    i += 1

print("saving tiles")
write_tile_set_2_CHR("bank.chr", tile_bank)


print("done")
