#include "tile.h"

uint8_t compare_spr_tile_px(
    const struct Tile *t1_lo,
    const struct Tile *t1_hi,
    const struct Tile *t2_lo,
    const struct Tile *t2_hi,
    uint8_t flip)
{
    // init cmp_val
    uint8_t cmp_val = 0;
    //
    uint8_t h = flip & 0x01;
    uint8_t v = flip & 0x02;
    if (v)
    {
        for (int y = 0; y < TILE_H; y++)
            for (int x = 0; x < TILE_W; x++)
            {
                // compare if it is the same pixel or not
                uint8_t t2_x = (h) ? TILE_W - x - 1 : x;
                uint8_t t2_y = TILE_H - y - 1;
                cmp_val += t1_lo->pixels[y][x] != t2_hi->pixels[t2_y][t2_x];
                cmp_val += t1_hi->pixels[y][x] != t2_lo->pixels[t2_y][t2_x];
            }
    }
    else
    {
        for (int y = 0; y < TILE_H; y++)
            for (int x = 0; x < TILE_W; x++)
            {
                // compare if it is the same pixel or not
                uint8_t t2_x = (h) ? TILE_W - x - 1 : x;
                cmp_val += t1_lo->pixels[y][x] != t2_lo->pixels[y][t2_x];
                cmp_val += t1_hi->pixels[y][x] != t2_hi->pixels[y][t2_x];
            }
    }

    // return the computed compare value
    return cmp_val;
}

void compare_spr_tiles(
    const struct Tile tile_list[MAX_TILES],
    const struct Tile *tile_lo,
    const struct Tile *tile_hi,
    uint8_t compare_value[MAX_SPR_TILES],
    uint8_t flip, uint16_t *argmin, int *first_free, uint8_t *free_cmp_val)
{
    // init first_same & first_free
    *argmin = 0;
    *first_free = -1;

    // create empty tile and compare it to the tile
    struct Tile empty_tile;
    empty_tile.type = TILE_TYPE_FREE;
    for (int i = 0; i < TILE_BIN_SIZE; i++)
        empty_tile.binary[i] = 0;
    tile_bin2pix(&empty_tile);
    (*free_cmp_val) = compare_spr_tile_px(&empty_tile, &empty_tile, tile_lo, tile_hi, flip);

    // for each tile
    // struct Tile t = tile_list[0];
    for (int i = 0; i < MAX_SPR_TILES; i++)
    {
        struct Tile t_lo = tile_list[i * 2];
        struct Tile t_hi = tile_list[i * 2 + 1];
        // if tile is free
        if (t_lo.type == TILE_TYPE_FREE && t_hi.type == TILE_TYPE_FREE)
        {
            // update first_free if needed
            if (*first_free < 0)
                *first_free = i;
            // update the compare value array
            // with the already computed value
            compare_value[i] = (*free_cmp_val);
        }
        else
        {
            // compare it with the alone tile
            // and update the compare value array
            compare_value[i] = compare_spr_tile_px(&t_lo, &t_hi, tile_lo, tile_hi, flip);
        }
        // update argmin if needed
        if (compare_value[i] < compare_value[*argmin])
            *argmin = i;
    }
}
