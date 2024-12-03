import argparse
import itertools
import os
import numpy as np
from glob import glob
from snif_decode import snif_decode
from snif_encode import snif_encode_data
from const import *
from tqdm import tqdm
from tile import tiles2chr


class CantFit(Exception):
    pass


def find_tile_idx(tile, tiles, tile_hashes={}, firstonly=True, MIN_PIXEL_EQUALITY=DEFAULT_PX_EQUA):
    # if empty tile
    if tiles.shape[0] == 0:
        # return default value
        return -1 if firstonly else []

    # if already seen tile
    # h = str(hash(tile.tobytes()))
    # if h in tile_hashes:
    #     # return its index
    #     if firstonly:
    #         return tile_hashes[h]
    #     return [v for k, v in tile_hashes.items() if h == k]

    # compare to each tile
    # tmp = np.array(tile == tiles, int)
    # idx = np.where(np.einsum('...ijk->i...', tmp) >= MIN_PIXEL_EQUALITY)
    # idx = np.where(compute_tile_dif(tile, tiles, MIN_PIXEL_EQUALITY))
    s = np.sum(tile == tiles, axis=(2, 1))
    idx = np.where(s >= MIN_PIXEL_EQUALITY)

    # if not found
    if len(idx[0]) == 0:
        # return default value
        return -1 if firstonly else []

    # return found tiles in best order
    if np.unique(s[idx[0]]).size > 1:
        s_idx = np.flip(np.argsort(s[idx[0]], kind="stable"))
        idx = np.take(idx[0], s_idx)
    else:
        idx = np.sort(idx[0])

    # idx = list(np.sort(idx[0]))
    if firstonly:
        return idx[0]
    return idx


def test_region_bkg(data, bkg_bnk_tiles, spr_mask, tiles, tile_hashes={}, MIN_PIXEL_EQUALITY=DEFAULT_PX_EQUA):
    adrs = data["bkg_adr"]
    nulltile = np.zeros((8, 8), dtype=np.uint8)

    new_adr = np.array([], dtype=np.uint16)

    # for each tile address use in background image
    for a in adrs:
        # get the used tile
        t = tiles[a]
        # if tile already in bank
        i = find_tile_idx(t, bkg_bnk_tiles, tile_hashes, MIN_PIXEL_EQUALITY=MIN_PIXEL_EQUALITY)
        if i >= 0:
            # use this tile instead
            new_adr = np.append(new_adr, i)
            continue
        # if empty tile to replace in bank
        iz = find_tile_idx(nulltile, bkg_bnk_tiles, tile_hashes, False, MIN_PIXEL_EQUALITY)
        iz = [i for i in iz if not spr_mask[i]]
        if len(iz) > 0:
            # use this tile instead
            new_adr = np.append(new_adr, iz[0])
            # and change tile
            bkg_bnk_tiles[iz[0]] = t
            continue
        # else no tile found
        raise CantFit("No More Background tile found")

    # bkg_bnk_tiles was already changed by reference
    return new_adr


def spr_inside_bnk(spr, tile_up, tile_down, bnk, tile_hashes={}, MIN_PIXEL_EQUALITY=DEFAULT_PX_EQUA):
    def find_tile(tu, td):
        tu_i = find_tile_idx(tu, bnk, tile_hashes, False, MIN_PIXEL_EQUALITY)
        td_i = find_tile_idx(td, bnk, tile_hashes, False, MIN_PIXEL_EQUALITY)
        for i in tu_i:
            for j in td_i:
                if i >= 0 and i % 2 == 0 and i + 1 == j:
                    spr[2] = i
                    return spr

    # TODO: test for offsets
    # no flip
    s = find_tile(tile_up, tile_down)
    if s:
        s[4] = False
        s[5] = False
        return s
    # with H flip
    s = find_tile(np.flip(tile_up, axis=1), np.flip(tile_down, axis=1))
    if s:
        s[4] = True
        s[5] = False
        return s
    # with V flip
    s = find_tile(np.flip(tile_down, axis=0), np.flip(tile_up, axis=0))
    if s:
        s[4] = False
        s[5] = True
        return s
    # with HV flip
    s = find_tile(np.flip(tile_down), np.flip(tile_up))
    if s:
        s[4] = True
        s[5] = True
        return s


def free_spr_bnk_mask(b, spr_bnk_tiles, spr_mask, nulltile, TPB=SPR_PER_BNK * 2):
    bnk = spr_bnk_tiles[b * TPB : b * TPB + TPB]
    nulltile_bnk_mask = np.all(nulltile == bnk, axis=(2, 1))
    spr_bnk_mask = ~spr_mask[b * TPB : b * TPB + TPB]
    free_mask_1 = np.logical_and(nulltile_bnk_mask[::2], spr_bnk_mask[::2])
    free_mask_2 = np.logical_and(nulltile_bnk_mask[1::2], spr_bnk_mask[1::2])
    free_mask = np.logical_and(free_mask_1, free_mask_2)
    return free_mask


def test_region_spr(data, spr_bnk_tiles, spr_mask, tiles, tile_hashes={}, MAX_BNK_COMBI=DEFAULT_MAX_BNK_COMBI, MIN_PIXEL_EQUALITY=DEFAULT_PX_EQUA):
    TPB = SPR_PER_BNK * 2  # TPB = TILE PER BANK

    spr = data["spr_data"]
    ori_spr = spr.copy()
    if len(spr) == 0:
        return [-1] * 8, []
    spr_bnk = data["bnk"]

    # init arrays
    bnk_score = np.zeros(256, dtype=np.uint8)
    bnk_free = np.zeros(256, dtype=np.uint8)
    new_spr = []

    # compute number of free sprite per bank
    nulltile = np.zeros((8, 8), dtype=np.uint8)
    for b in range(256):
        free_mask = free_spr_bnk_mask(b, spr_bnk_tiles, spr_mask, nulltile)
        bnk_free[b] = np.sum(free_mask)

    # compute score (how many tile is present)
    # of each bank for each sprite
    bnks = [spr_bnk_tiles[b * TPB : b * TPB + TPB] for b in range(256)]
    for i, s in enumerate(spr):
        # read sprite data
        ti = s[2]
        b = spr_bnk[ti >> 5]
        ti = (ti & 0x1F) * 2
        # get sprite tiles
        tile_up = tiles[b * TPB + ti + 0]
        tile_down = tiles[b * TPB + ti + 1]
        # for each bank
        for b in range(256):
            # get bank
            bnk = bnks[b]
            # if tiles in bank
            new_s = spr_inside_bnk(s.copy(), tile_up, tile_down, bnk, tile_hashes, MIN_PIXEL_EQUALITY)
            if new_s:
                # add new sprite
                new_spr.append((b, new_s, i))
                # and increase bank score
                bnk_score[b] += 1

    # compute possible arrangment of CHR bank for sprites
    comb_list = np.argsort(bnk_score * -1, kind="stable")[:MAX_BNK_COMBI]
    bnk_combi = np.array(list(itertools.combinations(comb_list, 8)), dtype=np.uint8)
    # compute score for each arrangment
    combi_score = np.array([np.sum(bnk_score[x]) for x in bnk_combi]) * -1
    # sort by best to worst
    idxs = np.argsort(combi_score)
    combi_score = np.take(combi_score, idxs)
    bnk_combi = np.take(bnk_combi, idxs, axis=0)
    # take the first best that fit all sprites
    fit = False
    i = 0
    while i < len(bnk_combi):
        # if total number of sprite < total free sprites
        new_spr_with_bnk = []
        for x in new_spr:
            if x[0] in bnk_combi[i] and x[2] not in [y[2] for y in new_spr_with_bnk]:
                new_spr_with_bnk.append(x)
        nb_free = np.sum(bnk_free[bnk_combi[i]])
        if len(spr) - len(new_spr_with_bnk) <= nb_free:
            # take this bank arrangment
            best_bnk = bnk_combi[i]
            fit = True
            break
        i += 1

    # if no bank arrangment was found
    if not fit:
        # take the most empty one
        idxs = np.argsort(bnk_free)
        best_bnk = idxs[-8:]
        # if total number of sprite < total free sprites
        new_spr_with_bnk = []
        for x in new_spr:
            if x[0] in best_bnk and x[2] not in [y[2] for y in new_spr_with_bnk]:
                new_spr_with_bnk.append(x)
        # new_spr_with_bnk = [x for x in new_spr if x[0] in best_bnk]
        nb_free = np.sum(bnk_free[best_bnk])
        if len(spr) - len(new_spr_with_bnk) <= nb_free:
            # take this bank arrangment
            fit = True

    # if that didn't work either
    if not fit:
        raise CantFit("No More Sprite Banks")

    #
    new_idxs = [x[2] for x in new_spr_with_bnk]
    new_spr = []
    #
    for i in range(len(spr)):
        # new sprite with old tiles
        if i in new_idxs:
            s = new_spr_with_bnk[new_idxs.index(i)]
        # old sprite with new tiles
        else:
            assert ori_spr == spr
            s = spr[i]
            # read sprite data
            ti = s[2]
            b = spr_bnk[ti >> 5]
            ti = (ti & 0x1F) * 2
            # get sprite tiles
            tile_up = tiles[b * TPB + ti + 0]
            tile_down = tiles[b * TPB + ti + 1]
            if b == -1:
                print(s)
                print(s[2],( s[2] >> 5), b, ti)
                print(spr_bnk)
                print(spr_bnk[0])
                print(tile_up)
                print(tile_down)
                exit(1)
            # find where to put the new tile
            bnk_idx = 0
            tile_idx = -1
            #
            while tile_idx < 0:
                if bnk_idx >= 8:
                    print("Error: That should not have happened. There is a bug somewhere maybe in 'test_region_spr' function")
                    print(best_bnk, bnk_free[best_bnk], sum(bnk_free[best_bnk]), len(new_spr_with_bnk), idx)
                    exit(1)
                cur_bnk = spr_bnk_tiles[best_bnk[bnk_idx] * TPB : best_bnk[bnk_idx] * TPB + TPB]
                #
                free_mask = free_spr_bnk_mask(best_bnk[bnk_idx], spr_bnk_tiles, spr_mask, nulltile)
                # find empty sprite
                idx = find_tile_idx(nulltile, cur_bnk, tile_hashes, False, MIN_PIXEL_EQUALITY)
                idx = [idx[j] for j in range(len(idx)) if idx[j] % 2 == 0 and free_mask[idx[j] // 2]]
                # if found
                if len(idx) >= 1:
                    # put it there
                    tile_idx = idx[0]
                    spr_bnk_tiles[best_bnk[bnk_idx] * TPB + tile_idx + 0] = tile_up
                    spr_bnk_tiles[best_bnk[bnk_idx] * TPB + tile_idx + 1] = tile_down
                    s[2] = tile_idx
                    s = (best_bnk[bnk_idx], s, i)
                    break
                # continue
                bnk_idx += 1

        spr_mask[(s[0] * TPB) + s[1][2]] = True
        spr_mask[(s[0] * TPB) + s[1][2] + 1] = True
        s[1][2] //= 2
        s[1][2] += list(best_bnk).index(s[0]) << 5
        new_spr.append(s[1])

    # remove unused banks
    best_bnk = list(best_bnk)
    use_bnk = np.unique([x[2] >> 5 for x in new_spr])
    for i in range(8):
        if i not in use_bnk:
            best_bnk[i] = -1

    return best_bnk, new_spr


def test_region(data, all_tiles, spr_mask, img_tiles, tile_hashes={}, MIN_PIXEL_EQUALITY=DEFAULT_PX_EQUA):
    try:
        ok = 1
        # test to compact background tiles
        new_adr = test_region_bkg(data, all_tiles, spr_mask, img_tiles, tile_hashes, MIN_PIXEL_EQUALITY)
        ok = 2
        # test to compact sprite tiles
        new_bnk, new_spr = test_region_spr(data, all_tiles, spr_mask, img_tiles, tile_hashes, MIN_PIXEL_EQUALITY=MIN_PIXEL_EQUALITY)
    except CantFit:
        return False, ()
    return ok, (new_bnk, new_adr, new_spr, all_tiles, spr_mask)


def compact(files: list, n_region=4, reg_offset=0, MIN_PIXEL_EQUALITY=DEFAULT_PX_EQUA, add_size=False, reserved_tiles=5):
    # Variables
    nulltile = np.zeros((8, 8), dtype=np.uint8)
    all_tiles = np.array([[nulltile] * 1024 * 16] * n_region, dtype=np.uint8)
    for r in range(n_region):
        all_tiles[r][2] = nulltile + 1
        all_tiles[r][3] = nulltile + 2
        all_tiles[r][4] = nulltile + 3
    all_tiles_hash = {}
    spr_tile_mask = np.zeros((n_region, 1024 * 16), dtype=bool)
    spr_tile_mask[:, 0:reserved_tiles] = True
    main_snif_file = bytearray()
    images_offset = []

    bar = files
    bar = tqdm(files, desc="Compact Images", dynamic_ncols=True)
    for file in bar:
        bar.set_description(f"Compacting ({os.path.basename(file)})")
        # read file
        with open(file, "rb") as f:
            data = f.read()
        # decode file
        data = snif_decode(data)

        for i, img_data in enumerate(data["imgs"]):
            inserted = False
            for r in range(n_region):
                reg_tiles = all_tiles[r]
                reg_spr_mask = spr_tile_mask[r]
                tile_hashes = dict([(str(hash(x.tobytes())), i) for i, x in enumerate(all_tiles[r])])
                ok, changes = test_region(img_data, reg_tiles, reg_spr_mask, data["chr"], tile_hashes, MIN_PIXEL_EQUALITY)
                if ok:
                    inserted = True
                    # unpack changes
                    new_bnk, new_adr, new_spr, new_reg_tiles, new_reg_spr_mask = changes
                    # apply changes
                    all_tiles[r] = new_reg_tiles
                    spr_tile_mask[r] = new_reg_spr_mask
                    img_data["bnk"] = new_bnk
                    img_data["bkg_adr"] = new_adr
                    img_data["spr_data"] = new_spr
                    img_data["header"]["c"] = 1
                    img_data["header"]["r"] = r + reg_offset
                    break
            if not inserted:
                raise CantFit("No place in any region")

            # encode compact image
            img_data = snif_encode_data(img_data)
            #
            images_offset.append(len(main_snif_file))
            # and append it to main file
            if add_size:
                main_snif_file.extend((len(img_data) + 2).to_bytes(2, "little"))
            main_snif_file.extend(img_data)
    chr_offset = len(main_snif_file)
    print("Number of tiles:", [np.sum(np.any(nulltile != all_tiles[r], axis=(2, 1))) for r in range(n_region)])
    print("Number of sprite tiles:", [np.sum(x) for x in spr_tile_mask])
    # add CHR to file
    for i in range(n_region):
        main_snif_file.extend(tiles2chr(all_tiles[i]))

    return main_snif_file, images_offset, chr_offset


if __name__ == "__main__":
    # Argmuents
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input_folder", dest="folder", required=True)
    parser.add_argument("-o", "--out", default="merge.snif")
    args = parser.parse_args()

    # Find files
    files = glob("**/*.snif", root_dir=args.folder, recursive=True)
    if args.out in files:
        del files[files.index(args.out)]
    print(f"Found {len(files)} files")

    main_snif_file, images_offset, chr_offset = compact(files)
    nb_image = len(images_offset)

    # Write output file
    print("Write output file")
    with open(args.out, "wb") as f:
        # metadata of file
        metadata = f'{{"version":0,"mapper":5,"nbimg":{nb_image}}}'
        f.write(bytes(metadata, encoding="utf-8"))
        f.write(main_snif_file)

    print("Done!")
