from rle_inc import *


def find_palettes(character_img):
    palettes = []

    colors = character_img.getcolors()  # get character colors
    idxs = [v for _, v in colors]  # keep color order befor sorting
    colors = colors[1:]  # remove background color
    # sort by color count
    colors = sorted(colors, key=lambda tup: tup[0], reverse=True)
    colors = [v for _, v in colors]  # remove color count from list

    # background image in gray scale, palette already sorted
    palettes.append([0, 1, 2, 3])
    palettes.append([  # character primary palette
        0,
        idxs.index(colors[0])+3 if len(colors) > 0 else 4,
        idxs.index(colors[1])+3 if len(colors) > 1 else 4,
        idxs.index(colors[2])+3 if len(colors) > 2 else 4,
    ])
    palettes.append([  # character/background palette
        0,
        idxs.index(colors[0])+3 if len(colors) > 0 else 4,
        2,
        3
    ])

    palettes.append([  # character secondary palette
        0,
        idxs.index(colors[3])+3 if len(colors) > 3 else 4,
        idxs.index(colors[4])+3 if len(colors) > 4 else 4,
        idxs.index(colors[5])+3 if len(colors) > 5 else 4,
    ])

    return palettes


def merge_image(background_img, character_img):
    b = np.array(background_img)
    c = np.array(character_img)
    c = np.where(c == 0, c-1, c+3)
    c = np.where(c == 3, 0, c)
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
    
    # pad if needed
    for i in range(len(spr_tile)):
        if spr_tile[i].shape != (SPR_SIZE_H, SPR_SIZE_W):
            shape = np.shape(spr_tile[i])
            pad_spr = np.zeros((SPR_SIZE_H, SPR_SIZE_W), dtype=int)
            pad_spr[:shape[0],:shape[1]] = spr_tile[i]
            spr_tile[i] = pad_spr

    # get map
    spr_map = [i for i in range(len(spr_tile))]

    return spr_tile, spr_map, info


def encode_frame(background_img_path, character_img_path, spr_bank=[]):

    # reduce color count to 4 for background and 7 (+1 for transparent) for character
    background_img, pal = bkg_col_reduce(background_img_path)
    character_img, pal_chr = char_col_reduce(character_img_path)

    background_img = img_2_idx(background_img)
    character_img = img_2_idx(character_img)

    # find the NES palette
    # bp0 = background  sp0 = char sec
    # bp1 = char prim   sp1 = ...
    # bp2 = contour     sp2 = ...
    # bp3 = ...         sp3 = ...
    palettes = find_palettes(character_img)

    # merge background and character into 1 image
    frame = merge_image(background_img, character_img)

    # remove sprite colors from background
    # get sprite layer
    frame_spr = frame
    for i in range(0, 4):
        frame_spr = np.where(frame_spr == palettes[0][i], 0, frame_spr)
        frame_spr = np.where(frame_spr == palettes[1][i], 0, frame_spr)
        frame_spr = np.where(frame_spr == palettes[2][i], 0, frame_spr)
    # convert it to range 0-3
    for i in range(1, 4):
        frame_spr = np.where(frame_spr == palettes[3][i], i, frame_spr)

    tmp_spr_bank = spr_bank.copy()
    # convert sprite frame to tiles
    spr_tile, spr_map, spr_info = img_2_spr(frame_spr)
    # copy tile to bank and remove duplicate
    spr_tile, spr_map, tmp_spr_bank = rm_closest_spr_tiles(spr_tile, spr_map, tmp_spr_bank)

    base_spr_idx = (len(tmp_spr_bank) // SPR_BANK_PAGE_SIZE)*SPR_BANK_PAGE_SIZE
    nb_spr = sum([1 if s != base_spr_idx else 0 for s in spr_map])

    if nb_spr > MAX_SPRITE_COUNT:
        print(f"WARNING: too many sprite ({nb_spr})")

    spr_bank = tmp_spr_bank
    for i in range(len(spr_map)):
        spr_map[i] %= SPR_BANK_PAGE_SIZE
    spr_info["b"] = len(spr_bank) // SPR_BANK_PAGE_SIZE

    spr_data = [spr_info["w"], spr_info["b"], spr_info["x"], spr_info["y"]]
    spr_data.extend(spr_map)

    return spr_data, spr_bank, pal, pal_chr
