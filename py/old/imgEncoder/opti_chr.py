from tqdm import tqdm

from rle_inc import *

def opti_chrrom_space(CHR_rom, spr_bank_start, frames):
    # rearrange tile to take less space
    free_tiles_adr = free_tiles(CHR_rom, spr_bank_start)
    print("free tiles found:", len(free_tiles_adr))
    tile2fix = []
    spr2fix = []
    for spr_adr in free_tiles_adr:
        tile_adr = last_use_tile(CHR_rom, spr_bank_start)
        CHR_rom = swap_tile(CHR_rom, spr_adr, tile_adr)
        tile2fix.append(tile_adr)
        spr2fix.append(spr_adr)

    # nb_spr_tile = 0
    # t = np.array(CHR_rom[:spr_bank_start*4096])
    # s = np.array(CHR_rom[spr_bank_start*4096:])
    # for i in tqdm(range(spr_bank_start*4096-16, -16, -16), "replace similar background tiles by sprites tiles"):
    #     t1 = t[i:i+16]
    #     for j in range(spr_bank_start*4096, len(CHR_rom), 16):
    #         t2 = s[j:j+16]
    #         if np.array_equal(t1,t2):
    #             nb_spr_tile += 1
    #             tile2fix.append(i//16)
    #             spr2fix.append(j//16)
    #             CHR_rom[i:i+16] = bytes(16)
    #             break
    # print("number of similar tiles in sprites found:", nb_spr_tile)

    spr_data_start = []
    for i in tqdm(range(len(frames)), "fix tilemaps"):
        # get tilemap
        tile_data_idx, spr_data_idx, tilemap, palmap = decode_tilemap(frames[i])
        spr_data = frames[i][spr_data_idx:]
        # replace tiles
        for j in range(len(tilemap)):
            if tilemap[j] in tile2fix:
                k = tile2fix.index(tilemap[j])
                tilemap[j] = spr2fix[k]
        # convert tilemap to more compressible data (all low bytes, then all high bytes)
        data = []
        for t in tilemap:
            data.append(t % 256)
        for j, t in enumerate(tilemap):
            data.append(t // 256 + (palmap[j] << 6))
        # encode tilemap
        tilemap = rleinc_encode(data)
        frames[i] = frames[i][:tile_data_idx]
        frames[i].extend(tilemap)
        spr_data_start.append(len(frames[i]))
        frames[i].extend(spr_data)

    print("remove unused bank")
    b = spr_bank_start*4096-16

    offset = 0
    SPR_BNK_SIZE = SPR_BANK_PAGE_SIZE*32
    while sum(CHR_rom[b:b+16]) == 0:
        offset += 16
        b -= 16
    offset //= SPR_BNK_SIZE
    if offset:
        del CHR_rom[(spr_bank_start*4096)-(offset*SPR_BNK_SIZE):spr_bank_start*4096]

    print("fix spritemaps")
    for i in range(len(frames)):
        if frames[i][0] & 0x10:
            idx = spr_data_start[i]+1
            frames[i][idx] -= offset
    
    return CHR_rom, frames


def free_tiles(CHR_rom, spr_bank_start):
    free_tiles_adr = []
    adr = spr_bank_start*4096
    while adr < len(CHR_rom):
        if sum(CHR_rom[adr:adr+32]) == 0:
            free_tiles_adr.append(adr//16)
            free_tiles_adr.append((adr//16)+1)
        adr += 32
    return free_tiles_adr


def last_use_tile(CHR_rom, spr_bank_start):
    adr = (spr_bank_start*4096)-16
    while sum(CHR_rom[adr:adr+16]) == 0:
        adr -= 16
    return adr // 16


def swap_tile(CHR_rom, spr_adr, tile_adr):
    s = CHR_rom[spr_adr*16:spr_adr*16+16]
    t = CHR_rom[tile_adr*16:tile_adr*16+16]
    for i in range(16):
        CHR_rom[spr_adr*16+i] = t[i]
        CHR_rom[tile_adr*16+i] = s[i]
    return CHR_rom


def decode_tilemap(frame):
    tile_data_idx = 1
    if frame[0] & 0x40:
        tile_data_idx = frame.index(0xFF)+1
    tilemap, idx = rleinc_decode(frame[tile_data_idx:])
    spr_data_idx = tile_data_idx+idx
    tilemap = [tilemap[i] + (tilemap[256*3+i] << 8) for i in range(256*3)]
    palmap = [t // (256*64) for t in tilemap]
    tilemap = [t % (256*64) for t in tilemap]
    return tile_data_idx, spr_data_idx, tilemap, palmap
