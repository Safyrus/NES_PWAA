import argparse
import hashlib
import itertools
import numpy as np
from tqdm import tqdm
from PIL import Image
from sewar import mse
from nes_pal import closest_color, closest_nes_color, NES_PAL


def split_img_2_bkg_and_spr_np(img: Image.Image, bkg_pals: list[tuple[int, int, int]], transparent_threshold=56, backdrop=(0, 0, 0, 255)) -> tuple[Image.Image, Image.Image]:
    # init variables
    img_tw = (img.width // 8) + int(img.width % 8 != 0)
    img_th = (img.height // 8) + int(img.height % 8 != 0)
    transparent_idx = 0
    backdrop_idx = 1

    # init arrays
    bkg_img = np.zeros((img.height, img.width), dtype=int)
    spr_img = np.zeros((img.height, img.width), dtype=int)
    atr_img = np.full((img_th, img_tw), -1, dtype=int)

    # get image colors
    img_colors = [x[1] for x in img.getcolors() if x[1][3] == 255 and x[1] != backdrop]
    img_colors.insert(0, backdrop)
    img_colors.insert(0, (0, 0, 0, 0))
    # convert image to numpy array
    img_np = np.zeros((img.height, img.width), dtype=int)
    img_data = np.reshape(np.array(img.getdata()), (img.height, img.width, 4))
    for i, c in enumerate(img_colors):
        img_np[(c == img_data).all(axis=-1)] = i

    # for each tile
    for y in range(0, img.height, 8):
        for x in range(0, img.width, 8):
            # get tile
            tw = min(x + 8, img.width)
            th = min(y + 8, img.height)
            tile = img_np[y:th, x:tw]
            colors, count = np.unique(tile, return_counts=True)
            have_transparent = transparent_idx in colors

            # skip empty tile
            if len(colors) == 1 and colors[0] == 0:
                continue
            # if transparent and any color
            if have_transparent:
                # if too much transparent
                n_transparent = count[np.where(colors == transparent_idx)][0]
                if n_transparent > transparent_threshold:
                    # put tile in spr_img
                    spr_tile = spr_img[y:th, x:tw]
                    # without erasing previous data
                    mask = tuple((np.argwhere(spr_tile == transparent_idx) + [y, x]).T)
                    spr_img[mask] = img_np[mask]
                    # skip this tile
                    continue
                # else replace transparent with backdrop
                idx = np.argwhere(tile == transparent_idx)
                tile[tuple(idx.T)] = backdrop_idx

            # find best palette
            scores = []
            for p in bkg_pals:
                s = 0
                # compute palette score
                # (pixel color distance from NES color * pixel count)
                for i in range(len(colors)):
                    n, c = count[i], colors[i]
                    _, d = closest_color(p, img_colors[c], return_dist=True)
                    s += n * d
                scores.append(s)
            # get best palette
            i = np.argmin(scores)
            atr_img[y // 8, x // 8] = i
            best_pal = bkg_pals[i]
            # apply best palette
            for c in colors:
                # skip "non-color"
                if c == backdrop_idx or c == transparent_idx:
                    continue
                # choose best color from best palette
                i, d = closest_color(best_pal, img_colors[c], return_dist=True)
                # if color not in best palette
                if d > 1:
                    # put wrong pixels in spr
                    spr_tile = spr_img[y:th, x:tw]
                    mask = tuple((np.argwhere((spr_tile == transparent_idx) & (tile == c)) + [y, x]).T)
                    spr_img[mask] = img_np[mask]
                # replace color by best color
                tile[tile == c] = img_colors.index(best_pal[i])
            bkg_img[y:th, x:tw] = tile

    # rebuild images from numpy array
    bkg_img = Image.fromarray(np.uint8(bkg_img))
    bkg_img.putpalette(np.array(img_colors, dtype=np.uint8), rawmode="RGBA")
    spr_img = Image.fromarray(np.uint8(spr_img))
    spr_img.putpalette(np.array(img_colors, dtype=np.uint8), rawmode="RGBA")

    return bkg_img, spr_img, atr_img, img_colors


def find_spr(spr_img: np.ndarray, pos: tuple[int, int], pal_offset=1, take_first=False):
    x, y = pos
    h = min(spr_img.shape[0], y + 16)
    w = min(spr_img.shape[1], x + 8)
    best_off = (0, 0)
    best_px = 0
    best_pal = [pal_offset, pal_offset + 1, pal_offset + 2]

    # find the best offset that give the sprite with the most pixels
    # for each offset
    for oy in range(16):
        for ox in range(8):
            # get sprite
            s = spr_img[y + oy : h + oy, x + ox : w + ox]
            nb_px = np.count_nonzero(s)
            # if sprite have more pixels than the best found
            if best_px < nb_px:
                # find palette
                for i in range(pal_offset, np.max(s) + 3, 3):
                    idxs = (s >= i) & (s <= i + 2)
                    nb_px = np.count_nonzero(s[idxs])
                    if best_px < nb_px:
                        # save this sprite
                        best_px = nb_px
                        best_off = (ox, oy)
                        best_pal = [i, i + 1, i + 2]
            # stop if take first
            if take_first:
                break
        if take_first:
            break

    return best_off, best_pal, best_px


def compute_line_overflow(h, sprites):
    lines = []
    for _ in range(h):
        lines.append([])
    for y in range(h):
        for i, s in enumerate(sprites):
            if s[1] <= y < s[1] + 16:
                lines[y].append(i)
    return lines


def remove_spr_overflow_line(h, sprites):
    lines = compute_line_overflow(h, sprites)
    while np.max([len(l) for l in lines]) > 8:
        scores = [0] * len(sprites)
        for l in lines:
            for i in l:
                img = np.array(sprites[i][6].copy().convert("P"))
                n = (16 * 8) - np.count_nonzero(img)
                scores[i] += len(l) * n
        i = np.argmax(scores)
        del sprites[i]
        lines = compute_line_overflow(h, sprites)


def remove_spr_overflow_num(sprites):
    while len(sprites) > 64:
        scores = []
        for s in sprites:
            img = np.array(s[6].copy().convert("P"))
            scores.append(np.count_nonzero(img))
        del sprites[np.argmin(scores)]


def img2neslimit(img_path: str, verbose=False, no_bkg=False, no_spr=False, no_spr_offset=False, BACKDROP=(0, 0, 0, 255), bkg_pal=None):
    # read image
    img: Image.Image = Image.open(img_path)
    hash = hashlib.sha256(img.tobytes()).hexdigest()
    img = img.convert("RGBA")
    colors = sorted(img.getcolors(), key=lambda x: x[0], reverse=True)
    FORCED_THRESHOLD = 2 / len(colors)
    counts = [x[0] for x in img.getcolors() if x[1][3] == 255 and x[1] != BACKDROP]
    colors = [x[1] for x in img.getcolors() if x[1][3] == 255 and x[1] != BACKDROP]
    forced_colors = [i for i, x in enumerate(img.getcolors()) if x[1][3] == 255 and x[1] != BACKDROP and x[0] / sum(counts) > FORCED_THRESHOLD]

    if no_bkg or len(colors) == 0:
        best_sim = 1e100
        bkg_pal = []
        np_img = np.array(img)
        NONE_COLOR = (255, 0, 255, 0)
        pal = [
            [NONE_COLOR, NONE_COLOR, NONE_COLOR],
            [NONE_COLOR, NONE_COLOR, NONE_COLOR],
        ]
        bkg_img, spr_img, _, new_colors = split_img_2_bkg_and_spr_np(img, pal, backdrop=NONE_COLOR)
    else:
        # get all background palette permutations
        if bkg_pal:
            bkg_palettes = bkg_pal[0][1:4]
            bkg_palettes.extend(bkg_pal[1][1:4])
            #
            new_bkg_palettes = [-1]*len(bkg_palettes)
            for i in range(len(colors)):
                c = closest_nes_color(colors[i])
                for j in range(len(bkg_palettes)):
                    if bkg_palettes[j] == c:
                        new_bkg_palettes[j] = i
            bkg_palettes = [new_bkg_palettes]
            forced_colors = []
        else:
            bkg_palettes = list(itertools.permutations(range(len(colors))))
        bkg_palettes = [np.append(sorted(x[0:3]), sorted(x[3:6])) for x in bkg_palettes if len(forced_colors) == 0 or np.all(np.isin(forced_colors, x[0:6]))]
        bkg_palettes = np.array(np.unique(bkg_palettes, axis=0), dtype=int)

        # find the best background palette
        best_sim = 1e100
        bkg_img = Image.new("RGBA", img.size)
        spr_img = Image.new("RGBA", img.size)
        bkg_pal = []
        new_colors = None
        np_img = np.array(img)
        for bp in tqdm(bkg_palettes, disable=not verbose):
            pals = [
                [
                    colors[bp[0]] if len(bp) > 0 else BACKDROP,
                    colors[bp[1]] if len(bp) > 1 else BACKDROP,
                    colors[bp[2]] if len(bp) > 2 else BACKDROP,
                ],
                [
                    colors[bp[3]] if len(bp) > 3 else BACKDROP,
                    colors[bp[4]] if len(bp) > 4 else BACKDROP,
                    colors[bp[5]] if len(bp) > 5 else BACKDROP,
                ],
            ]
            b, s, a, new_colors = split_img_2_bkg_and_spr_np(img, pals, backdrop=BACKDROP)
            score_sim = mse(np_img, np.array(b.convert("RGBA")))
            if score_sim < best_sim:
                best_sim = score_sim
                bkg_pal = [colors[bp[i]] if len(bp) > i else BACKDROP for i in range(6)]
                bkg_img = b
                spr_img = s

    if no_spr:
        return {
            "w": img.width,
            "h": img.height,
            "backdrop": np.array(BACKDROP),
            "hash": hash,
            "bkg_pal": bkg_pal,
            "spr_pal": [],
            "bkg_img": bkg_img.convert("RGBA"),
            "spr_img": None,
            "spr": [],
        }

    # remove backdrop color from sprite image
    tmp_spr_img = np.array(spr_img, dtype=int) - 1
    tmp_spr_img[tmp_spr_img < 0] = 0
    spr_colors = new_colors.copy()
    del spr_colors[1]
    spr_img = Image.fromarray(np.uint8(tmp_spr_img))
    spr_img.putpalette(np.array(spr_colors, dtype=np.uint8), rawmode="RGBA")

    # find sprites
    w = spr_img.width
    h = spr_img.height
    spr = []
    # for each spr_img tile
    for y in range(0, h, 16):
        for x in range(0, w, 8):
            # get tile
            tw = min(x + 8, w)
            th = min(y + 16, h)
            tile = tmp_spr_img[y:th, x:tw]
            # while opaque pixels remain
            while np.count_nonzero(tile):
                # find sprite
                offset, pal, _ = find_spr(tmp_spr_img, (x, y), take_first=no_spr_offset)
                ox, oy = offset
                # get sprite
                s_img = tmp_spr_img[y + oy : min(h, th + oy), x + ox : min(w, tw + ox)]
                tmp = s_img.copy()
                # with correct palette
                tmp[(tmp == pal[0]) | (tmp == pal[1]) | (tmp == pal[2])] = 0
                s_img[(s_img != pal[0]) & (s_img != pal[1]) & (s_img != pal[2])] = 0
                # add sprite to list
                s_im = Image.fromarray(np.uint8(s_img))
                s_im.putpalette(np.array(spr_colors, dtype=np.uint8), rawmode="RGBA")
                spr.append([x + ox, y + oy, None, None, None, None, s_im.convert("RGBA")])
                # remove pixel of sprite from spr_img
                tmp_spr_img[y + oy : th + oy, x + ox : tw + ox] = tmp
                tile = tmp_spr_img[y:th, x:tw]

    # remove sprites (because n > 64 or line overflow)
    remove_spr_overflow_line(h, spr)
    remove_spr_overflow_num(spr)

    return {
        "w": img.width,
        "h": img.height,
        "backdrop": np.array(BACKDROP),
        "hash": hash,
        "bkg_pal": bkg_pal if not no_bkg else [],
        "spr_pal": spr_colors[1:],
        "bkg_img": bkg_img.convert("RGBA") if not no_bkg else None,
        "spr_img": spr_img.convert("RGBA"),
        "spr": spr,
    }


if __name__ == "__main__":
    # argument
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--image", help="image path to convert to SNIF")
    args = parser.parse_args()

    # main
    # img_data = img2neslimit(args.image, verbose=True)
    img_data = img2neslimit(args.image, verbose=True, no_bkg=True, no_spr_offset=True)

    # results
    if img_data["bkg_img"]:
        img_data["bkg_img"].save("tmp_bkg.png")
    if img_data["spr_img"]:
        img_data["spr_img"].save("tmp_spr.png")
    print(f"sprites: ({len(img_data['spr'])})")
    for s in img_data["spr"]:
        print(s[0:2], s[6].size, s[6].mode)
