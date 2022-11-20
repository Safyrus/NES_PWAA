import sys
from PIL import Image

TILE_SIZE = 8
RLE_MIN = 3
RLE_MAX = 255
MIN_DIFF = 2
MAX_COLOR = 7

def get_tile(px, x, y):
    tile = []
    for i in range(TILE_SIZE):
        for j in range(TILE_SIZE):
            tile.append(px[x+j, y+i])
    return tile

def convert_tile(tile):
    img_tile = Image.new(mode="P", size=(TILE_SIZE, TILE_SIZE))
    for y in range(TILE_SIZE):
        for x in range(TILE_SIZE):
            img_tile.putpixel((x, y), tile[y*TILE_SIZE+x])
    img_pal = img_tile.quantize(colors=4, method=Image.MAXCOVERAGE)
    return get_tile(img_pal.load(), 0, 0), img_pal.getcolors()

def diff_tile(h1, h2):
    dif = 0
    for i in range(4):
        dif += abs(h1[i][0] - h2[i][0])
    return dif


def min_diff_tile(tile, tile_hist_buf):
    min = TILE_SIZE*TILE_SIZE*TILE_SIZE
    min_idx = -1
    for i in range(len(tile_hist_buf)):
        t = tile_hist_buf[i]
        d = diff_tile(tile, t)
        if d < min:
            min = d
            min_idx = i
        if min == 0:
            return min, min_idx
    return min, min_idx

def tile2chr(tile):
    chr = []
    #
    for y in range(TILE_SIZE):
        b = 0
        for x in range(TILE_SIZE):
            b |= (tile[(y*TILE_SIZE)+x] & 1) << (TILE_SIZE - 1 - x)
        chr.append(b)
    #
    for y in range(TILE_SIZE):
        b = 0
        for x in range(TILE_SIZE):
            b |= ((tile[(y*TILE_SIZE)+x] & 2) >> 1) << (TILE_SIZE - 1 - x)
        chr.append(b)
    return bytes(chr)

########
# MAIN #
########

# arguments
chrfile = "chr.chr"
romfile = "rom.bin"
imgfile = sys.argv[1]

# read image pixels, width and height
with Image.open(imgfile) as img:
    img = img.convert("L").convert("P", palette=1, colors=MAX_COLOR)
    px = img.load()
    w = img.width
    h = img.height

print(f"width: {w}   height: {h}")
print(f"number of tiles: {(w//TILE_SIZE)*(h//TILE_SIZE)}")

# 
tile_idx_buf = []
tile_chr_buf = []
tile_hash_buf = []
tile_hist_buf = []
dif_tile_count = 0

# process
for y in range(h//TILE_SIZE):
    print(f"process... ({y}/{h//TILE_SIZE})")
    for x in range(w//TILE_SIZE):
        # get the tile
        tile = get_tile(px, x*TILE_SIZE, y*TILE_SIZE)
        # limit number of color to 4 and convert color to range 0-3
        tile, hist = convert_tile(tile)
        hist = sorted(hist, key=lambda tup: tup[1])
        while len(hist) < 4:
            hist.append((0, len(hist)))
        hsh = hash(str(tile))
        # print(hsh)

        # if tile had been seen
        if hsh in tile_hash_buf:
            tile_idx_buf.append(tile_hash_buf.index(hsh))
            continue
        # else if tile is close to another tile
        diff, closest_tile_idx = min_diff_tile(hist, tile_hist_buf)
        if diff < MIN_DIFF:
            tile_idx_buf.append(closest_tile_idx)
            dif_tile_count += 1
            continue
        # else this is a new tile
        tile_idx_buf.append(len(tile_chr_buf))
        tile_hash_buf.append(hsh)
        tile_hist_buf.append(hist)
        tile_chr_buf.append(tile)

print(f"number of unique tiles: {len(tile_chr_buf)}")
print(f"number of tiles replaced: {dif_tile_count}")

# save CHR data
chrfile_size = 0
with open(chrfile, "wb") as chr:
    for t in tile_chr_buf:
        chr.write(tile2chr(t))
        chrfile_size += (TILE_SIZE*TILE_SIZE) // 4
# save image data
romfile_size = 0
with open(romfile, "wb") as rom:
    i = 0
    while i < len(tile_idx_buf):
        t = tile_idx_buf[i]

        j = i+1
        while j < len(tile_idx_buf) and (j - i) < RLE_MAX and tile_idx_buf[j] == t:
            j += 1

        t += 256

        if j - i > RLE_MIN:
            # print(i, j)
            rom.write((0).to_bytes(1, byteorder='big'))
            rom.write((j - i).to_bytes(1, byteorder='big'))
            rom.write(t.to_bytes(2, byteorder='big'))
            romfile_size += 4
        else:
            for k in range(j-i):
                rom.write(t.to_bytes(2, byteorder='big'))
                romfile_size += 2
        i = j

print(f"CHR size: {chrfile_size} bytes")
print(f"ROM size: {romfile_size} bytes")
