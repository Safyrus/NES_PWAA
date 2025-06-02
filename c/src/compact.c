#include <stdlib.h>
#include "tile.h"
#include "file_utils.h"
#include "compact.h"

int replace_bkg_tile(uint8_t *tile_cmp_matrix, struct Tile tile_list[MAX_TILES], const struct Tile *tile, uint8_t compare_value[MAX_TILES], int argmin)
{
    // old_tile_index = argmin(compare_value)
    int old_tile_index = argmin;
    // old_tile = tile_list[old_tile_index]
    struct Tile *old_tile = &tile_list[old_tile_index];
    // if old_tile.reserved
    if (old_tile->type == TILE_TYPE_RES)
        // use the old one and return its index
        return old_tile_index;

    // new_tile_score = sum(compare_value)
    int new_tile_score = 0;
    for (int i = 0; i < MAX_TILES; i++)
        new_tile_score += compare_value[i];
    // old_tile_score = sum(tile_cmp_matrix[old_tile_index])
    int old_tile_score = 0;
    for (int i = 0; i < MAX_TILES; i++)
        old_tile_score += tile_cmp_matrix[old_tile_index * MAX_TILES + i];
    // if old_tile_score > new_tile_score
    if (old_tile_score > new_tile_score)
        // use the old one and return its index
        return old_tile_index;

    // replace old tile by new one
    tile_list[old_tile_index] = *tile;
    // update compare_value
    compare_value[old_tile_index] = 0;
    // replace row and column at old_tile_index by compare_value
    for (int i = 0; i < MAX_TILES; i++)
    {
        tile_cmp_matrix[old_tile_index * MAX_TILES + i] = compare_value[i];
        tile_cmp_matrix[i * MAX_TILES + old_tile_index] = compare_value[i];
    }
    // use the new one and return its index
    return old_tile_index;
}

int add_bkg_tile(uint8_t *tile_cmp_matrix, struct Tile tile_list[MAX_TILES], const struct Tile *tile)
{
    // compare the tile to the tile_list
    uint8_t compare_value[MAX_TILES];
    int argmin, first_free, free_count;
    compare_tiles(tile_list, tile, compare_value, &argmin, &first_free, &free_count);

    // if the tile we want to add is reserved
    if (tile->type == TILE_TYPE_RES)
    {
        // then replace the free tile by the one we want to add
        tile_list[first_free] = *tile;
        // plus update the correct line in tile_cmp_matrix
        for (int i = 0; i < MAX_TILES; i++)
            tile_cmp_matrix[first_free * MAX_TILES + i] = compare_value[i];
        // and return this index
        return first_free;
    }

    // if a tile is similar enought to another tile
    if (compare_value[argmin] <= BKG_SIMILAR_THRESHOLD)
    {
        // then the tile is already in the list
        // and we return this index
        return argmin;
    }

    // else, if there is a free tile in the list
    // without getting over BKG_MAX_TILES
    if (first_free >= 0 && free_count >= (MAX_TILES-BKG_MAX_TILES))
    {
        // then replace the free tile by the one we want to add
        tile_list[first_free] = *tile;
        // plus update the correct line in tile_cmp_matrix
        for (int i = 0; i < MAX_TILES; i++)
            tile_cmp_matrix[first_free * MAX_TILES + i] = compare_value[i];
        // and return this index
        return first_free;
    }

    // otherwise, we find the closest tile availible
    // to use instead of or replace by the tile we want to add
    // and return its index
    return replace_bkg_tile(tile_cmp_matrix, tile_list, tile, compare_value, argmin);
}

void merge_chrs(const char *final_chr)
{
    // open final CHR file
    FILE *foutchr = fopen_strict(final_chr, "wb");

    // for each region
    char chrpath[11] = "out/r0.chr";
    for (int r = 0; r < 4; r++)
    {
        // open region file
        chrpath[5] = '0' + r;
        FILE *f = fopen_strict(chrpath, "rb");

        // copy data
        char tilebuf[16];
        for (int i = 0; i < MAX_TILES; i++)
        {
            if (fread(tilebuf, 16, 1, f) != 1)
            {
                for (int j = 0; j < 16; j++)
                    tilebuf[j] = 0;
            }
            fwrite(tilebuf, 16, 1, foutchr);
        }

        fclose(f);
    }

    fclose(foutchr);
}

uint16_t replace_spr_tile(
    uint8_t *tile_cmp_matrix,
    struct Tile tile_list[MAX_TILES],
    uint8_t compare_value[4][MAX_SPR_TILES],
    uint16_t argmin,
    uint8_t *out_flip)
{
    // old_tile_index = argmin(compare_value)
    int old_tile_index = argmin;
    // old_tile = tile_list[old_tile_index]
    struct Tile *old_tile_lo = &tile_list[old_tile_index * 2 + 0];
    struct Tile *old_tile_hi = &tile_list[old_tile_index * 2 + 1];
    // if old_tile.reserved
    if ((old_tile_lo->type & -(1 + TILE_TYPE_MASK_REPLACE)) == TILE_TYPE_RES ||
        (old_tile_hi->type & -(1 + TILE_TYPE_MASK_REPLACE)) == TILE_TYPE_RES)
    {
        // use the old one and return its index
        (*out_flip) = 0;
        return old_tile_index;
    }

    // new_tile_score = sum(compare_value)
    int new_tile_score[4];
    for (int f = 0; f < 4; f++)
    {
        new_tile_score[f] = 0;
        for (int i = 0; i < MAX_SPR_TILES; i++)
            new_tile_score[f] += compare_value[f][i];
    }
    // old_tile_score = sum(tile_cmp_matrix[old_tile_index])
    int old_tile_score[4];
    for (int f = 0; f < 4; f++)
    {
        old_tile_score[f] = 0;
        for (int i = 0; i < MAX_SPR_TILES; i++)
        {
            int idx = (f * MAX_SPR_TILES * MAX_SPR_TILES) + old_tile_index * MAX_SPR_TILES + i;
            old_tile_score[f] += tile_cmp_matrix[idx];
        }
    }
    // if old_tile_score > new_tile_score
    int best_flip = -1;
    int best_score = 0;
    for (int f = 0; f < 4; f++)
        if (old_tile_score[f] > new_tile_score[f] && old_tile_score[f] > best_score)
        {
            best_flip = f;
            best_score = old_tile_score[f];
        }
    if (best_flip >= 0)
    {
        // use the old one and return its index
        (*out_flip) = best_flip;
        return old_tile_index;
    }

    // else mark old tile to be replaced
    tile_list[old_tile_index * 2].type |= TILE_TYPE_MASK_REPLACE;
    tile_list[old_tile_index * 2 + 1].type |= TILE_TYPE_MASK_REPLACE;
    // and return its index
    (*out_flip) = 0;
    return old_tile_index;
}

uint16_t add_spr_tile(
    uint8_t *tile_cmp_matrix,
    struct Tile tile_list[MAX_TILES],
    const struct Tile *tile_lo,
    const struct Tile *tile_hi,
    uint8_t *out_flip)
{
    // compare the sprite to the tile_list
    uint8_t compare_value[4][MAX_SPR_TILES];
    int first_free;
    uint8_t free_cmp_val;
    uint16_t argmin[4];
    for (int f = 0; f < 4; f++)
        compare_spr_tiles(tile_list, tile_lo, tile_hi, compare_value[f], f, &argmin[f], &first_free, &free_cmp_val);

    // if the tile we want to add is reserved
    if ((tile_lo->type & -(1 + TILE_TYPE_MASK_REPLACE)) == TILE_TYPE_RES ||
        (tile_hi->type & -(1 + TILE_TYPE_MASK_REPLACE)) == TILE_TYPE_RES)
    {
        // mark the tile to be replaced
        tile_list[first_free * 2 + 0].type |= TILE_TYPE_MASK_REPLACE;
        tile_list[first_free * 2 + 1].type |= TILE_TYPE_MASK_REPLACE;
        // and return this index
        (*out_flip) = 0;
        return first_free;
    }

    // if the sprite has too little pixels
    if (free_cmp_val < SPR_MIN_PX_THRESHOLD)
    {
        // assign it the null sprite
        (*out_flip) = 0;
        return 0;
    }

    // else if the tile is 'close enought'
    uint8_t best_val = 255;
    int8_t best_flip = -1;
    for (int f = 0; f < 4; f++)
        if (compare_value[f][argmin[f]] < SPR_SIMILAR_THRESHOLD && compare_value[f][argmin[f]] < best_val)
        {
            best_val = compare_value[f][argmin[f]];
            best_flip = f;
        }
    if (best_flip >= 4)
    {
        fprintf(stderr, "Error (add_spr_tile): flip is not valid (%d)\n", best_flip);
        exit(1);
    }
    if (best_flip >= 0)
    {
        (*out_flip) = (uint8_t)best_flip;
        return argmin[best_flip];
    }
    // else, if there is a free tile in the list
    if (first_free >= 0)
    {
        // mark the tile to be replaced
        tile_list[first_free * 2 + 0].type |= TILE_TYPE_MASK_REPLACE;
        tile_list[first_free * 2 + 1].type |= TILE_TYPE_MASK_REPLACE;
        // and return this index
        (*out_flip) = 0;
        return first_free;
    }

    // otherwise, we can't fit the sprite
    // and assign it the null sprite
    (*out_flip) = 0;
    return 0;

    // otherwise, we find the closest tile availible
    // to use instead of or replace by the tile we want to add
    // and return its index
    return replace_spr_tile(tile_cmp_matrix, tile_list, compare_value, argmin[0], out_flip);
}
