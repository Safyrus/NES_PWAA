import argparse
import copy
import itertools
import numpy as np
from tqdm import tqdm
from PIL import Image, ImageDraw
import hashlib
from const import *


class Score:
    def __init__(self, w: int, h: int) -> None:
        self.wrong_bkg_mask = np.zeros((h, w), np.uint8)
        self.wrong_spr_mask = np.zeros((h, w), np.uint8)
        self.wrong_black_mask = np.zeros((h, w), np.uint8)
        self.sprite_count = 0
        self.spr_overflow_count = 0
        self.line_overflow_count = 0

    def _count_1_in_mask(mask: Image.Image) -> int:
        return np.sum(mask)

    def wrong_bkg_count(self) -> int:
        return Score._count_1_in_mask(self.wrong_bkg_mask)

    def wrong_spr_count(self) -> int:
        return Score._count_1_in_mask(self.wrong_spr_mask)

    def wrong_black_count(self) -> int:
        return Score._count_1_in_mask(self.wrong_black_mask)

    def __str__(self) -> str:
        s = "Score:\n"
        s += f"- Wrong background pixel: {self.wrong_bkg_count()}\n"
        s += f"- Wrong sprite pixel: {self.wrong_spr_count()}\n"
        s += f"- Added black pixel: {self.wrong_black_count()}\n"
        s += f"- Sprite count: {self.sprite_count}\n"
        s += f"- Sprite overflow count: {self.spr_overflow_count}\n"
        s += f"- Line overflow count: {self.line_overflow_count}\n"
        return s

    def sum(self):
        return self.wrong_bkg_count() + self.wrong_spr_count() + self.wrong_black_count() + self.sprite_count + self.spr_overflow_count + self.line_overflow_count

    def _save_mask(mask: Image.Image, name: str):
        i = Image.fromarray(mask * 255, "L")
        i.save(name)

    def save_masks(self, prefix: str):
        Score._save_mask(self.wrong_bkg_mask, prefix + "_bkg.png")
        Score._save_mask(self.wrong_spr_mask, prefix + "_spr.png")
        Score._save_mask(self.wrong_black_mask, prefix + "_blk.png")


def move_spr_color(tile_data, not_bkg_pal, sprimg, bkg_pal, pos, score):
    # if tile have color not in bkg_pal
    idxs = [np.where(np.all(tile_data == not_bkg_pal[i], axis=-1)) for i in range(len(not_bkg_pal))]
    if idxs:
        i = np.concatenate(idxs, axis=-1)
        if i is not None and i[0].size > 0:
            sprpart = tile_data.copy()
            mask = np.ones((8, 8), dtype=bool)
            mask[i] = False
            sprpart[mask, ...] = (0, 0, 0, 0)
            # add tile with only (not bkg_pal) to spr_img
            sprimg.paste(Image.fromarray(sprpart), pos)

        # fill not bkg_pal color with closest color
        if FILL_BLACK:
            for i in idxs:
                tile_data[i] = np.array(BLACK)
                score.wrong_bkg_mask[(i[0] + pos[1]), (i[1] + pos[0])] = 1
        else:
            for j, i in enumerate(idxs):
                dists = np.sqrt(np.sum((bkg_pal - not_bkg_pal[j]) ** 2, axis=1))
                tile_data[i] = bkg_pal[np.argmin(dists)]
                score.wrong_bkg_mask[(i[0] + pos[1]), (i[1] + pos[0])] = 1

    return tile_data, sprimg, score


def find_palette(tile: Image.Image, pal_col, bkg_col=np.array(BLACK)):
    tile_col = np.array([x[1] for x in tile.getcolors()])
    px = np.array([x[0] for x in tile.getcolors()])
    total_px = np.sum(px)
    nb_pal = (len(pal_col) // 3) + bool(len(pal_col) % 3)

    have_bkg = np.all(bkg_col == tile_col, axis=-1)
    pals = [np.append([bkg_col], pal_col[i * 3 : i * 3 + 3], axis=0) for i in range(nb_pal)]

    if np.any(have_bkg):
        tile_col = np.delete(tile_col, have_bkg, axis=0)
        px = np.delete(px, have_bkg, axis=0)
        total_px = np.sum(px)
    have_pals = []
    for i in range(nb_pal):
        if FILL_BLACK:
            h = [np.any(np.all(x == pal_col[i * 3 : i * 3 + 3], axis=-1)) for x in tile_col]
        else:
            h = [int(np.any(np.all(tile_col[j] == pal_col[i * 3 : i * 3 + 3], axis=-1))) * (px[j] / total_px) for j in range(len(px))]
        have_pals.append(h)

    have_pals = np.array(have_pals)
    # print(have_pals)
    # input()
    if len(tile_col) == 0:
        return pals, [0] * len(have_pals)
    else:
        return pals, (np.sum(have_pals, axis=-1))
        # return pals, (np.sum(have_pals, axis=-1) / len(tile_col))


def find_offset(sprimg: Image.Image, pos: tuple[int, int, int, int], take_first=False):
    x, y, xw, yh = pos
    best_off = None
    best_px = 0
    for oy in range(16):
        for ox in range(8):
            opos = (x + ox, y + oy, ox + xw, oy + yh)
            spr = sprimg.crop(opos)
            nb_px = np.sum([x[0] for x in spr.getcolors() if x[1][3] != 0])
            #
            if not best_off or best_px < nb_px:
                best_px = nb_px
                best_off = opos
            # take first solution and leave
            if take_first:
                break
        if take_first:
            break
    return best_off, best_px


def compute_overflow(h, sprites, score):
    score.spr_overflow_count = 0
    score.line_overflow_count = 0
    for s in sprites:
        s[4] = False
    lines = np.zeros(h)
    for y in range(h):
        for s in sprites:
            if s[1] <= y < s[1] + 16:
                lines[y] += 1
                if lines[y] > MAX_SPRITE_OVERFLOW:
                    s[4] = True
    # lines = np.array(lines)
    score.line_overflow_count = np.sum(lines > MAX_SPRITE_OVERFLOW)
    score.spr_overflow_count = sum([x[4] for x in sprites])
    return score, lines


def _remove_sprite(a, best_spr, best_sprimg, best_score, h, emptyspr):
    idx = np.argmax(a)
    spr = best_spr[idx]
    spr_data = np.array(spr[6])
    # find pixels in spr
    mask = ~((spr_data == np.array([0, 0, 0, 0])).all(axis=2))
    dif = np.where(mask)
    # add them to error mask
    best_score.wrong_spr_mask[dif[0] + spr[1], dif[1] + spr[0]] = 1
    best_sprimg.paste(emptyspr, spr[0:4], Image.fromarray(mask))
    # remove the sprite
    del best_spr[idx]
    # update score
    best_score.sprite_count -= 1
    best_score, best_lines = compute_overflow(h, best_spr, best_score)
    return best_score, best_lines, best_score


def remove_useless_sprites(best_spr, best_bkg_img, best_score, h, verbose):
    if verbose:
        print("Remove useless sprites...")
    before = len(best_spr)
    still_useless = True
    while still_useless:
        still_useless = False
        for i, x in enumerate(best_spr):
            b = np.array(best_bkg_img.crop(x[0:4]))
            if x[5] < MIN_PX_SPR or np.sum(np.all(b == np.array(x[6]), axis=-1)) == x[5]:
                still_useless = True
                best_score.sprite_count -= 1
                del best_spr[i]
                break

    best_score, best_lines = compute_overflow(h, best_spr, best_score)

    if verbose:
        print(f"Removed {before-len(best_spr)} sprites")
    return best_spr, best_lines, best_score


def remove_sprites(best_spr, best_sprimg, best_bkg_img, best_score, h, verbose, emptyspr):
    if verbose:
        print("Remove sprites...")
    before = len(best_spr)
    best_lines = []
    while len(best_spr) > MAX_SPRITE:
        # get sprite with the least pixels
        a = []
        for x in best_spr:
            v = x[5] * (BORDER_FACTOR if x[7] else 1)
            b = np.array(best_bkg_img.crop(x[0:4]))
            v -= np.sum(np.all(b == np.array(x[6]), axis=-1))  # remove pixels same as background
            a.append(v)
        # remove it
        best_score, best_lines, best_score = _remove_sprite(a, best_spr, best_sprimg, best_score, h, emptyspr)
    if verbose:
        print(f"Removed {before-len(best_spr)} sprites")
    return best_spr, best_lines, best_score, best_sprimg


def remove_overflows(best_spr, best_lines, best_sprimg, best_score, h, verbose, emptyspr):
    if verbose:
        print("Remove overflow...")
    before = len(best_spr)
    while np.sum(best_lines > MAX_SPRITE_OVERFLOW) > MAX_LINE_OVERFLOW:
        # get sprite with the most overflow and the lest pixel of same overflow
        a = [0] * len(best_spr)
        for j, l in enumerate(best_lines):
            if l > MAX_SPRITE_OVERFLOW:
                for i, x in enumerate(best_spr):
                    if x[1] <= j < (x[1] + 16):
                        a[i] += 1000
        for i, x in enumerate(best_spr):
            a[i] -= x[5]
        # remove it
        best_score, best_lines, best_score = _remove_sprite(a, best_spr, best_sprimg, best_score, h, emptyspr)
    if verbose:
        print(f"Removed {before-len(best_spr)} sprites")
    return best_spr, best_lines, best_score, best_sprimg


def img2neslimit(img_path: str, lazy_spr_pal=True, verbose=False, MAX_BKG_COLOR=6, MAX_SPR_COLOR=9, no_bkg=False, no_offset=False):
    ################
    # Read Image
    ################
    # Open image
    if verbose:
        print("Opening Image...")
    img: Image.Image = Image.open(img_path)
    hash_val = hashlib.sha256(img.tobytes()).hexdigest()
    # Convert to RGBA if not already the case
    if img.mode != "RGBA":
        if verbose:
            print("Warning: not a RGBA image. Converting...")
        img = img.convert("RGBA")
    # Get width and height
    w = img.width
    h = img.height
    # Same but in tile and sprite unit
    nb_bkgtile_w = (w // 8) + int(w % 8 != 0)
    nb_bkgtile_h = (h // 8) + int(h % 8 != 0)
    nb_sprtile_w = (w // 8) + int(w % 8 != 0)
    nb_sprtile_h = (h // 16) + int(h % 16 != 0)
    # Get color palette
    colors = [x[1] for x in img.getcolors()]  # only color, not count
    colors_no_a = np.array([x for x in colors if x[3] != 0])
    colors_no_ba = np.array([x for x in colors if np.any(x != (0, 0, 0, 255)) and x[3] != 0])
    if colors_no_a.size == 0:
        return {
            "bkg_img": Image.new("RGBA", img.size),
            "bkg_pal": [],
            "spr_img": Image.new("RGBA", img.size),
            "spr_pal": [],
            "spr": [],
            "score": Score(w, h),
            "overflow_lines": [],
            "w": w,
            "h": h,
            "backdrop": np.array(BLACK),
            "hash": hash_val,
        }
    # add to max color
    # (should help choosing better palette
    #  when we have less color than the max)
    i = 0
    MAX_COLOR = max(MAX_BKG_COLOR, MAX_SPR_COLOR)
    colors = np.array(colors)
    colors_no_a = np.array([x for x in colors if x[3] != 0])
    colors_no_ba = np.array([x for x in colors if np.any(x != (0, 0, 0, 255)) and x[3] != 0])
    # Count color
    nb_color_no_ba = len(colors_no_ba)
    nb_color_no_a = len(colors_no_a)
    nb_semi_px = len([x for x in colors if x[3] != 0 and x[3] != 255])

    ################
    # Guards
    ################
    if verbose:
        print("Checking Image...")
    if w < MIN_IMG_WIDTH:
        print(f"Error: {img_path} too small. Width must be at least {MIN_IMG_WIDTH}.")
        exit(1)
    if h < MIN_IMG_HEIGHT:
        print(f"Error: {img_path} too small. Height must be at least {MIN_IMG_HEIGHT}.")
        exit(1)
    if w > MAX_IMG_WIDTH:
        print(f"Error: {img_path} too big. Width must be at most {MAX_IMG_WIDTH}.")
        exit(1)
    if h > MAX_IMG_HEIGHT:
        print(f"Error: {img_path} too big. Height must be at most {MAX_IMG_HEIGHT}.")
        exit(1)
    if nb_semi_px > 0:
        print(f"Error: {img_path} has {nb_semi_px} colors with semi-transparency detected. Remove them.")
        exit(1)
    if nb_color_no_ba > MAX_COLOR:
        print(f"Error: {img_path} has too much colors. {nb_color_no_ba} detected, must be at most {MAX_COLOR}.")
        exit(1)
    if verbose:
        print("Image OK")

    ################
    # Permutation of palettes
    ################
    if verbose:
        print("Compute possible palettes...")
    if no_bkg:
        bkg_palettes = []
    else:
        bkg_palettes = list(itertools.permutations(range(nb_color_no_ba)))
        bkg_palettes = np.unique([np.append(sorted(x[0:3]), sorted(x[3:6])) for x in bkg_palettes], axis=0)
        bkg_palettes = np.array(bkg_palettes, dtype=int)
    if lazy_spr_pal:
        spr_palettes = [[0] * MAX_SPR_COLOR]
    else:
        spr_palettes = list(itertools.permutations(range(nb_color_no_a)))
        spr_palettes = np.unique(
            [
                np.append(
                    np.append(
                        sorted(x[0:3]),
                        sorted(x[3:6]),
                    ),
                    sorted(x[6:9]),
                )
                for x in spr_palettes
            ],
            axis=0,
        )
        spr_palettes = np.array(spr_palettes, dtype=int)
    if verbose:
        print("Possible palettes count (bkg,spr):", len(bkg_palettes), len(spr_palettes))

    #
    if no_bkg:
        best_score = Score(w, h)
        best_score.wrong_bkg_mask = np.ones((h, w), np.uint8)
        best_score.wrong_black_mask = np.ones((h, w), np.uint8)
        best_sprimg = img.copy()
        best_bkg_pal = []
        best_spr_pal = colors_no_ba.copy()
        best_bkg_img = Image.new("RGBA", (w, h))
    else:
        if verbose:
            print("Find best background palettes...")
        best_score = None
        best_sprimg = None
        best_bkg_pal = None
        best_spr_pal = None
        best_bkg_img = None
        emptytile = Image.new("RGBA", (8, 8))
        if verbose:
            bar = tqdm(bkg_palettes, desc=f"Score=???", dynamic_ncols=True)
        else:
            bar = bkg_palettes
        for bkg_pal in bar:
            # find invert of bkg_pal
            mask = np.ones(len(colors_no_ba), dtype=bool)
            mask[bkg_pal] = False
            not_bkg_pal = colors_no_ba[mask, ...].copy()
            # get color of bkg_pal
            bkg_pal_no_ba = colors_no_ba[bkg_pal]
            bkg_pal = list(bkg_pal_no_ba)
            bkg_pal.append(BLACK)
            bkg_pal = np.array(bkg_pal)
            # create score and sprite image
            score = Score(w, h)
            sprimg = Image.new("RGBA", (w, h))
            bkgimg = Image.new("RGBA", (w, h))
            # for every tile
            for y in range(nb_bkgtile_h):
                for x in range(nb_bkgtile_w):
                    # get tile
                    pos = (x * 8, y * 8, x * 8 + 8, y * 8 + 8)
                    tile = img.crop(pos)
                    tile_ori = img.crop(pos)
                    tile_data = np.array(tile)
                    tile_colors = tile.getcolors()
                    # if transparent
                    nb_transparent_px = sum([x[0] for x in tile_colors if x[1][3] == 0])
                    if nb_transparent_px:
                        # if transparent >= MAX_TRANSPARENT_PX
                        if nb_transparent_px >= MAX_TRANSPARENT_PX:
                            # add tile to spr_img
                            sprimg.paste(tile, pos)
                            # tile = blank
                            tile_data = np.array(emptytile.copy())
                        else:
                            tile_data, sprimg, score = move_spr_color(tile_data, not_bkg_pal, sprimg, bkg_pal, pos, score)
                            # fill transparency with black
                            i = np.where(tile_data[:, :, 3] == 0)
                            tile_data[i] = (0, 0, 0, 255)
                            # update wrong_black_color
                            score.wrong_black_mask[i[0] + (y * 8), i[1] + (x * 8)] = 1
                    # elif tile have color not in bkg_pal
                    else:
                        tile_data, sprimg, score = move_spr_color(tile_data, not_bkg_pal, sprimg, bkg_pal, pos, score)
                    tile = Image.fromarray(tile_data)
                    tile_colors = [x[1] for x in tile.getcolors()]

                    # if empty tile
                    if len(tile_colors) == 1 and tile_colors[0] == (0, 0, 0, 0):
                        pass
                    # if black tile
                    if len(tile_colors) == 1 and tile_colors[0] == (0, 0, 0, 255):
                        bkgimg.paste(tile, pos)
                    # else
                    else:
                        (ps, ns) = find_palette(tile, bkg_pal_no_ba)
                        # if no palette match
                        if np.all(ns != 1):
                            # take closest pal
                            p = ps[np.argmax(ns)]
                            p_rgb = np.array(np.delete(p, 3, 1).flatten(), dtype=np.uint8)
                            pal = Image.new("P", (0, 0))
                            pal.putpalette(p_rgb)
                            # new_tile = quantize(tile, closest_pal)
                            new_tile = tile.convert("RGB").quantize(4, QUANTIZE_STRAT, palette=pal, dither=True).convert("RGBA")
                            # find dif
                            mask = (np.array(tile) == np.array(new_tile)).all(axis=2)
                            dif = np.where(mask)
                            # wrong_bkg_color += dif
                            score.wrong_bkg_mask[dif[0] + (y * 8), dif[1] + (x * 8)] = 1
                            # update sprites
                            sprtile = np.array(tile.copy())
                            for c in p:
                                sprtile[(sprtile == c).all(axis=-1)] = np.array([0, 0, 0, 0])
                            sprtile = Image.fromarray(sprtile)
                            mask = Image.fromarray(~mask)
                            sprimg.paste(sprtile, pos, mask)
                            # update tile
                            tile = new_tile
                        bkgimg.paste(tile, pos)

                # abandon curent solution if already worst
                if best_score and score.sum() > best_score.sum():
                    break

            # keep the best found
            if not best_score or score.sum() < best_score.sum():
                best_score = score
                best_bkg_pal = bkg_pal_no_ba
                best_spr_pal = not_bkg_pal
                best_sprimg = sprimg
                best_bkg_img = bkgimg
                if verbose:
                    bar.set_description(f"Score={best_score.sum()}")

    #
    best_spr = []
    best_lines = np.array([])
    if MAX_SPR_COLOR > 0:
        if lazy_spr_pal:
            if no_bkg:
                a = best_spr_pal.copy()
            else:
                a = np.append(best_bkg_pal, best_spr_pal, axis=0)
            while len(a) < min(len(colors), MAX_SPR_COLOR):
                a = np.append(a, [BLACK], axis=0)
            spr_palettes = np.array([a])
        elif verbose:
            print("Find best sprite palettes...")
        # start with worst score for sprites
        best_score.sprite_count = w * h
        best_score.spr_overflow_count = best_score.sprite_count
        best_score.line_overflow_count = 256
        best_score.wrong_spr_mask = np.ones((h, w), dtype=np.uint8)
        # for every sprite palettes
        emptyspr = Image.new("RGBA", (8, 16))
        if verbose:
            bar = tqdm(spr_palettes, desc=f"Score=???", dynamic_ncols=True)
        else:
            bar = spr_palettes
        for spr_pal in bar:
            # setup variables
            sprimg = best_sprimg.copy()
            sprimg_final = Image.new("RGBA", (w, h))
            sprites = []
            # setup score
            score = copy.copy(best_score)
            score.sprite_count = 0
            score.spr_overflow_count = 0
            score.line_overflow_count = 0
            score.wrong_spr_mask = np.zeros((h, w), dtype=np.uint8)
            # get color of spr_pal
            spr_pal_no_a = spr_pal if lazy_spr_pal else colors_no_a[spr_pal]
            spr_pal = np.append(spr_pal_no_a, [[0, 0, 0, 0]], axis=0)
            # remove pixels already in background
            sprimg_data = np.array(sprimg)
            same_idx = np.where(np.all(np.array(best_bkg_img) == sprimg_data, axis=-1))
            sprimg_data[same_idx] = np.array([0, 0, 0, 0])
            sprimg = Image.fromarray(sprimg_data)
            # while pixel left on sprimg
            while np.sum((np.array(sprimg) == np.array([0, 0, 0, 0])).all(axis=2)) != w * h:
                # for each sprite grid position
                for y in range(nb_sprtile_h):
                    for x in range(nb_sprtile_w):
                        # find sprite with best offset
                        pos = (x * 8, y * 16, x * 8 + 8, y * 16 + 16)
                        offset, nb_px = find_offset(sprimg, pos, take_first=no_offset)
                        # if empty sprite
                        if nb_px == 0:
                            continue
                        # get sprite
                        spr = sprimg.crop(offset)
                        spr_colors = [x[1] for x in spr.getcolors()]
                        # find palette
                        (ps, ns) = find_palette(spr, spr_pal_no_a, bkg_col=np.array([0, 0, 0, 0]))
                        # take closest pal
                        p = ps[np.argmax(ns)]
                        # copy correct color into new sprite
                        spr_data = np.array(spr)
                        new_spr_data = np.zeros(spr_data.shape, dtype=np.uint8)
                        nb_px = 0
                        for c in p:
                            mask = (spr_data == c).all(axis=2)
                            if np.any(c != [0, 0, 0, 0]):
                                nb_px += np.sum(mask)
                            mask = np.where(mask)
                            new_spr_data[mask] = spr_data[mask]
                        # replace sprite with new one
                        spr = Image.fromarray(new_spr_data)
                        # update images
                        sprimg_final.paste(spr, offset, spr)
                        sprimg.paste(emptyspr, offset, spr)
                        # add sprite to list
                        sprites.append(list(offset))
                        border = 0 != sum([x[0] for x in (best_bkg_img.crop(offset)).getcolors() if x[1][3] == 0])
                        sprites[-1].extend([False, nb_px, spr, border])
                        # update score
                        score.sprite_count += 1

                        # abandon curent solution if already worst
                        if score.sum() > best_score.sum():
                            break
                    if score.sum() > best_score.sum():
                        break
                if score.sum() > best_score.sum():
                    break
            if score.sum() > best_score.sum():
                continue
            sprimg = sprimg_final

            # update overflow scores
            score, lines = compute_overflow(h, sprites, score)

            # keep the best found
            if score.sum() < best_score.sum():
                best_score = score
                best_spr = sprites
                best_sprimg = sprimg
                best_spr_pal = spr_pal_no_a
                best_lines = lines
                if verbose:
                    bar.set_description(f"Score={best_score.sum()}")

        #
        best_spr, best_lines, best_score = remove_useless_sprites(best_spr, best_bkg_img, best_score, h, verbose)
        if OVERFLOW_BEFOR_SPRITE:
            best_spr, best_lines, best_score, best_sprimg = remove_overflows(best_spr, best_lines, best_sprimg, best_score, h, verbose, emptyspr)
            best_spr, best_lines, best_score, best_sprimg = remove_sprites(best_spr, best_sprimg, best_bkg_img, best_score, h, verbose, emptyspr)
        else:
            best_spr, best_lines, best_score, best_sprimg = remove_sprites(best_spr, best_sprimg, best_bkg_img, best_score, h, verbose, emptyspr)
            best_spr, best_lines, best_score, best_sprimg = remove_overflows(best_spr, best_lines, best_sprimg, best_score, h, verbose, emptyspr)

    if verbose:
        print("Done!")

    return {
        "bkg_img": best_bkg_img,
        "bkg_pal": best_bkg_pal,
        "spr_img": best_sprimg,
        "spr_pal": best_spr_pal,
        "spr": best_spr,
        "score": best_score,
        "overflow_lines": np.array(best_lines),
        "w": w,
        "h": h,
        "backdrop": np.array(BLACK),
        "hash": hash_val,
    }


if __name__ == "__main__":
    # Arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--image", required=True)
    parser.add_argument("-lsp", "--lazy_spr_pal", action="store_true")
    parser.add_argument("-p", "--photo", action="store_true")
    args = parser.parse_args()
    lazy_spr_pal = args.lazy_spr_pal

    if args.photo:
        data = img2neslimit(args.image, lazy_spr_pal, True, 0, 9, True, True) # for evidence
    else:
        data = img2neslimit(args.image, lazy_spr_pal, verbose=True)
    w, h = data["w"], data["h"]

    # save line overflow as image
    line_data = np.repeat(np.ones(h, dtype=np.uint8) * (np.sum(data["overflow_lines"]) > MAX_SPRITE_OVERFLOW) * 255, w).reshape(h, w)
    Image.fromarray(line_data).save("test_line.png")
    # Display score and save images
    data["score"].save_masks("test")
    data["bkg_img"].save("test_bkgimg.png")
    data["spr_img"].save("test_sprimg.png")
    print("Background Palettes:")
    print(data["bkg_pal"])
    print("Sprites Palettes:")
    print(data["spr_pal"])
    print(data["score"])
    # sprites image
    sprite_img = Image.new("RGBA", (w, h))
    draw = ImageDraw.Draw(sprite_img)
    for i, s in enumerate(data["spr"]):
        v = int(255 * (i / len(data["spr"])))
        f = (v, 0, 0, 255) if s[4] else (0, 0, v, 255)
        draw.rectangle((s[0], s[1], s[2]-1, s[3]-1), fill=f)
    sprite_img.save("test_overflow.png")
