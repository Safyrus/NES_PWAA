from rle_inc import *
from rebuild import *


def grayscale_max(img):
    arr = np.array(img)
    arr *= 255//arr.max()
    return Image.fromarray(arr)


def find_palettes(_, character_img):
    palettes = []

    colors = character_img.getcolors()  # get character colors
    idxs = [v for _, v in colors]  # keep color order befor sorting
    colors = colors[2:]  # remove transparent and background color
    # sort by color count
    colors = sorted(colors, key=lambda tup: tup[0], reverse=True)
    colors = [v for _, v in colors]  # remove color count from list

    # background image in gray scale, palette already sorted
    palettes.append([0, 1, 2, 3])
    palettes.append([  # character primary palette
        0,
        idxs.index(colors[0])+2 if len(colors) > 0 else 4,
        idxs.index(colors[1])+2 if len(colors) > 1 else 4,
        idxs.index(colors[2])+2 if len(colors) > 2 else 4,
    ])
    palettes.append([  # character/background palette
        0,
        idxs.index(colors[0])+2 if len(colors) > 0 else 4,
        2,
        3
    ])

    palettes.append([  # character secondary palette
        0,
        idxs.index(colors[3])+2 if len(colors) > 3 else 4,
        idxs.index(colors[4])+2 if len(colors) > 4 else 4,
        idxs.index(colors[5])+2 if len(colors) > 5 else 4,
    ])

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
            count = np.count_nonzero(np.where(tile_set[i] == j, 1, 0))
            hist.append(count)

        # find best palette
        best_idx = 0
        best_count = 0
        for j in range(3):
            count = 0
            for k in range(4):
                p = palettes[j][k]
                count += hist[p]
            if count > best_count:
                best_idx = j
                best_count = count
        #
        pal_map.append(best_idx)
        pal = palettes[best_idx]

        # remove eccess colors
        isin_res = np.isin(tile_set[i], pal)
        tile_set[i] = np.where(isin_res, tile_set[i], 0)

        # replace color with palette
        for j in range(len(pal)):
            p = pal[j]
            tile_set[i] = np.where(tile_set[i] == p, j, tile_set[i])

    return tile_set, pal_map


def img_2_idx(img):
    c = img.getcolors()
    m = np.array(img)
    for i in range(len(c)):
        m = np.where(m == c[i][1], i, m)
    return Image.fromarray(m)


def find_img_box(img):
    # get image shape
    w, h = img.shape[0], img.shape[1]

    # init variables
    max_x, max_y = 0, 0,
    min_x = w-1
    min_y = h-1

    # loop
    for y in range(h):
        for x in range(w):
            #
            p = img[x, y]
            if not p:
                continue
            #
            if x < min_x:
                min_x = x
            if x > max_x:
                max_x = x
            if y < min_y:
                min_y = y
            if y > max_y:
                max_y = y

    # return result dict
    return {
        "x": min_y,
        "y": min_x,
        "w": max(0, max_y - min_y),
        "h": max(0, max_x - min_x)
    }


def img_2_spr(img):
    # Get sprite bounding box
    box = find_img_box(img)

    # save sprite pos and size
    info = {
        "x": box["x"],
        "y": box["y"],
        "w": box["w"]//SPR_SIZE_W+1,
        "h": box["h"]//SPR_SIZE_H+1
    }

    # transform image to array
    arr = np.array(img)
    arr = arr[box["y"]:box["y"]+(info["h"]*SPR_SIZE_H),
              box["x"]:box["x"]+(info["w"]*SPR_SIZE_W)]

    # get tiles
    h, w = arr.shape[0], arr.shape[1]
    spr_tile = [arr[y:y+SPR_SIZE_H, x:x+SPR_SIZE_W]
                for y in range(0, h, SPR_SIZE_H) for x in range(0, w, SPR_SIZE_W)]
    # get map
    spr_map = [i for i in range(len(spr_tile))]

    return spr_tile, spr_map, info


def encode_frame(background_img_path, character_img_path, tile_bank=[], spr_bank=[], tile_offset_hi=0):

    # reduce color count to 4 for background and 7 (+1 for transparent) for character
    background_img = bkg_col_reduce_2(background_img_path)
    character_img = char_col_reduce(character_img_path)

    background_img = img_2_idx(background_img)
    character_img = img_2_idx(character_img)

    grayscale_max(background_img).save("bck.png")
    grayscale_max(character_img).save("chr.png")

    # find the NES palette
    # bp0 = background  sp0 = char sec
    # bp1 = char prim   sp1 = ...
    # bp2 = contour     sp2 = ...
    # bp3 = ...         sp3 = ...
    palettes = find_palettes(background_img, character_img)

    # merge background and character into 1 image
    frame = merge_image(background_img, character_img)

    # remove sprite colors from background
    frame_nospr = frame
    for i in range(1, 4):
        frame_nospr = np.where(frame_nospr == palettes[3][i], 0, frame_nospr)
    grayscale_max(Image.fromarray(frame_nospr)).save("bckchr.png")
    # get sprite layer
    frame_spr = frame
    for i in range(0, 4):
        frame_spr = np.where(frame_spr == palettes[0][i], 0, frame_spr)
        frame_spr = np.where(frame_spr == palettes[1][i], 0, frame_spr)
        frame_spr = np.where(frame_spr == palettes[2][i], 0, frame_spr)
    # convert it to range 0-3
    for i in range(1, 4):
        frame_spr = np.where(frame_spr == palettes[3][i], i, frame_spr)
    grayscale_max(Image.fromarray(frame_spr)).save("spr.png")

    # convert frame to tiles
    tile_set, tile_map = img_2_tile(frame_nospr)
    # apply the palettes to the tiles
    tile_set, pal_map = apply_palette(tile_set, palettes)
    # remove similar tiles
    tile_set, tile_map, tile_bank = rm_closest_tiles(
        tile_set, tile_map, tile_bank)

    # convert sprite fraqme to tiles
    spr_tile, spr_map, spr_info = img_2_spr(frame_spr)
    # copy tile to bank and remove duplicate
    spr_tile, spr_map, spr_bank = rm_closest_spr_tiles(
        spr_tile, spr_map, spr_bank)
    spr_info["b"] = len(spr_bank) // SPR_BANK_PAGE_SIZE

    # convert tilemap to more compressable data (all low bytes, then all high bytes)
    data = []
    for t in tile_map:
        data.append(t % 256)
    for t in tile_map:
        data.append(((t//256) + tile_offset_hi) % 64)
    # put pal map into tile map
    for i in range(len(pal_map)):
        data[i+len(pal_map)] += (pal_map[i] << 6)
    # encode with RLE_INC data
    tile_map = rleinc_encode(data)
    spr_map = rleinc_encode(spr_map)
    spr_data = [spr_info["w"], spr_info["b"], spr_info["x"], spr_info["y"]]
    spr_data.extend(spr_map)

    return tile_map, tile_bank, spr_info, spr_data, spr_bank


if __name__ == "__main__":
    background_img_path = sys.argv[1]
    character_anim_path = sys.argv[2]
    tile_offset_hi = 0
    if len(sys.argv) > 3:
        tile_offset_hi = int(sys.argv[3])

    tile_bank = [
        np.full((TILE_SIZE, TILE_SIZE), 0),
        np.full((TILE_SIZE, TILE_SIZE), 1),
        np.full((TILE_SIZE, TILE_SIZE), 2),
        np.full((TILE_SIZE, TILE_SIZE), 3),
    ]
    spr_bank = [
        np.full((SPR_SIZE_H, SPR_SIZE_W), 0),
        np.full((SPR_SIZE_H, SPR_SIZE_W), 1),
        np.full((SPR_SIZE_H, SPR_SIZE_W), 2),
        np.full((SPR_SIZE_H, SPR_SIZE_W), 3),
    ]

    tile_map, tile_bank, spr_info, spr_map, spr_bank = encode_frame(
        background_img_path, character_anim_path, tile_bank, spr_bank, tile_offset_hi)

    # write tilemap to file
    with open("test_tile.bin", "wb") as chr:
        for t in tile_map:
            chr.write(t.to_bytes(1, "big"))
    # write sprite map to file
    with open("test_spr.bin", "wb") as chr:
        for t in spr_map:
            chr.write(t.to_bytes(1, "big"))

    # write CHR files
    write_tile_set_2_CHR("bank.chr", tile_bank)
    write_spr_tile_set_2_CHR("bank_spr.chr", spr_bank)
    if tile_offset_hi == 0:
        final_img = rebuild_frame_img(tile_map, spr_map, tile_bank, spr_bank)
        grayscale_max(final_img).save("out.png")
    else:
        print("TODO: rebuild image with offset")
