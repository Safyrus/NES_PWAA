from rle_inc import *
from collections import Counter

def find_palettes(_, character_img):
    palettes = []

    colors = character_img.getcolors() # get character colors
    idxs = [v for _,v in colors] # keep color order befor sorting
    colors = colors[2:] # remove transparent and background color
    colors = sorted(colors, key=lambda tup: tup[0], reverse=True) # sort by color count
    colors = [v for _,v in colors] # remove color count from list

    palettes.append([0, 1, 2, 3]) # background image in gray scale, palette already sorted
    palettes.append([ # character primary palette
        0,
        idxs.index(colors[0])+2,
        idxs.index(colors[1])+2,
        idxs.index(colors[2])+2
    ])
    palettes.append([ # character/background palette
        0,
        idxs.index(colors[0])+2,
        2,
        3
    ])
    palettes.append([0, 0, 0, 0]) # unused

    palettes.append([ # character secondary palette
        0,
        idxs.index(colors[3])+2,
        idxs.index(colors[4])+2,
        idxs.index(colors[5])+2
    ])
    palettes.append([0, 0, 0, 0]) # unused
    palettes.append([0, 0, 0, 0]) # unused
    palettes.append([0, 0, 0, 0]) # unused

    return palettes


def merge_image(background_img, character_img):
    b = np.array(background_img)
    c = np.array(character_img)
    c = np.where(c <= 1, c-1, c+2)
    frame = np.where(c == 255, b, c)
    return frame


def apply_palette(tile_set, palettes):
    pal_map = []

    for i in range(len(tile_set)):
        # find color by count
        hist = []
        for j in range(0, 10):
            hist.append(np.count_nonzero(np.any(tile_set[i] == j)))
        histpair = []
        # sort by max
        for j in range(len(hist)):
            idx = j if hist[j] > 0 else 0
            histpair.append((hist[j], idx))
        histpair = sorted(histpair, key=lambda tup: tup[0], reverse=True)[:4]
        hist_idx = [x for _,x in histpair]

        # remove excess colors
        for y in range(len(tile_set[i])):
            for x in range(len(tile_set[i][y])):
                p = tile_set[i][y][x]
                if p not in hist_idx:
                    tile_set[i][y][x] = 0

        # find best palette
        best_idx = 0
        best_count = 0
        t = tile_set[i].flatten()
        for j in range(4):
            count = []
            for k in range(4):
                if palettes[j][k] in t and palettes[j][k] not in count:
                    count.append(palettes[j][k])
            count = len(count)
            if count > best_count:
                best_idx = j
                best_count = count
        pal_map.append(best_idx)
        
        # replace color with palette
        for j in range(len(palettes[best_idx])):
            p = palettes[best_idx][j]
            tile_set[i] = np.where(tile_set[i] == p, j, tile_set[i])


    return tile_set, pal_map


def img_2_idx(img):
    c = img.getcolors()
    m = np.array(img)
    for i in range(len(c)):
        m = np.where(m == c[i][1], i, m)
    return Image.fromarray(m)


def encode_frame(background_img_path, character_img_path, tile_bank = []):

    # reduce color count to 4 for background and 7 (+1 for transparent) for character
    background_img = bkg_col_reduce_2(background_img_path)
    character_img = char_col_reduce(character_img_path)

    background_img = img_2_idx(background_img)
    character_img = img_2_idx(character_img)

    background_img.save("bck.png")
    character_img.save("chr.png")

    # find the NES palette
    # bp0 = background  sp0 = char sec
    # bp1 = char prim   sp1 = ...
    # bp2 = contour     sp2 = ...
    # bp3 = ...         sp3 = ...
    palettes = find_palettes(background_img, character_img)
    print(palettes)

    # merge background and character into 1 image
    frame = merge_image(background_img, character_img)
    Image.fromarray(frame).save("test.png")

    # remove sprite colors from background
    frame_nospr = frame
    for i in range(1, 4):
        frame_nospr = np.where(frame_nospr == palettes[4][i], 0, frame_nospr)
    # get sprite layer
    frame_spr = frame
    for i in range(0, 4):
        frame_spr = np.where(frame_spr == palettes[0][i], 0, frame_spr)
        frame_spr = np.where(frame_spr == palettes[1][i], 0, frame_spr)
        frame_spr = np.where(frame_spr == palettes[2][i], 0, frame_spr)

    # convert frame to tiles
    tile_set, tile_map = img_2_tile(frame_nospr)
    # apply the palettes to the tiles
    tile_set, pal_map = apply_palette(tile_set, palettes)
    # remove similar tiles
    tile_set, tile_map, tile_bank = rm_closest_tiles(tile_set, tile_map, tile_bank)

    # convert tilemap to more compressable data (all low bytes, then all high bytes)
    data = []
    for t in tile_map:
        data.append(t%256)
    for t in tile_map:
        data.append(t//256)
    # encode with RLE_INC the tilemap and palette map
    tile_map = rleinc_encode(data)
    pal_map = rleinc_encode(pal_map)

    return tile_map, pal_map, tile_bank


if __name__ == "__main__":
    background_img_path = sys.argv[1]
    character_anim_path = sys.argv[2]
    tile_map, pal_map, tile_bank = encode_frame(background_img_path, character_anim_path)

    # write tilemap to file
    with open("test_tile.bin", "wb") as chr:
        for t in tile_map:
            chr.write(t.to_bytes(1, "big"))
    # write palette map to file
    with open("test_pal.bin", "wb") as chr:
        for t in pal_map:
            chr.write(t.to_bytes(1, "big"))
    # write CHR file
    write_tile_set_2_CHR("bank.chr", tile_bank)
