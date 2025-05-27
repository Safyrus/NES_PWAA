#include <stdio.h>
#include <stdint.h>

#include "tile.h"

const uint8_t BITCOUNT[256] = {
    0,
    1,
    1,
    2,
    1,
    2,
    2,
    3,
    1,
    2,
    2,
    3,
    2,
    3,
    3,
    4,
    1,
    2,
    2,
    3,
    2,
    3,
    3,
    4,
    2,
    3,
    3,
    4,
    3,
    4,
    4,
    5,
    1,
    2,
    2,
    3,
    2,
    3,
    3,
    4,
    2,
    3,
    3,
    4,
    3,
    4,
    4,
    5,
    2,
    3,
    3,
    4,
    3,
    4,
    4,
    5,
    3,
    4,
    4,
    5,
    4,
    5,
    5,
    6,
    1,
    2,
    2,
    3,
    2,
    3,
    3,
    4,
    2,
    3,
    3,
    4,
    3,
    4,
    4,
    5,
    2,
    3,
    3,
    4,
    3,
    4,
    4,
    5,
    3,
    4,
    4,
    5,
    4,
    5,
    5,
    6,
    2,
    3,
    3,
    4,
    3,
    4,
    4,
    5,
    3,
    4,
    4,
    5,
    4,
    5,
    5,
    6,
    3,
    4,
    4,
    5,
    4,
    5,
    5,
    6,
    4,
    5,
    5,
    6,
    5,
    6,
    6,
    7,
    1,
    2,
    2,
    3,
    2,
    3,
    3,
    4,
    2,
    3,
    3,
    4,
    3,
    4,
    4,
    5,
    2,
    3,
    3,
    4,
    3,
    4,
    4,
    5,
    3,
    4,
    4,
    5,
    4,
    5,
    5,
    6,
    2,
    3,
    3,
    4,
    3,
    4,
    4,
    5,
    3,
    4,
    4,
    5,
    4,
    5,
    5,
    6,
    3,
    4,
    4,
    5,
    4,
    5,
    5,
    6,
    4,
    5,
    5,
    6,
    5,
    6,
    6,
    7,
    2,
    3,
    3,
    4,
    3,
    4,
    4,
    5,
    3,
    4,
    4,
    5,
    4,
    5,
    5,
    6,
    3,
    4,
    4,
    5,
    4,
    5,
    5,
    6,
    4,
    5,
    5,
    6,
    5,
    6,
    6,
    7,
    3,
    4,
    4,
    5,
    4,
    5,
    5,
    6,
    4,
    5,
    5,
    6,
    5,
    6,
    6,
    7,
    4,
    5,
    5,
    6,
    5,
    6,
    6,
    7,
    5,
    6,
    6,
    7,
    6,
    7,
    7,
    8,
};

void tile_bin2pix(struct Tile *tile)
{
    for (int y = 0; y < 8; y++)
        for (int x = 0; x < 8; x++)
        {
            char b0 = (tile->binary[y] >> (7 - x)) & 0x01;
            char b1 = (tile->binary[y + 8] >> (7 - x)) & 0x01;
            tile->pixels[y][x] = b0 | (b1 << 1);
        }
}

void print_tile(const struct Tile *tile)
{
    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            printf("%d ", tile->pixels[i][j]);
        }
        printf("\n");
    }
}

uint8_t compare_tile_bin(const struct Tile *t1, const struct Tile *t2)
{
    // init cmp_val
    uint8_t cmp_val = 0;
    // for each binary value
    for (int i = 0; i < TILE_BIN_SIZE; i++)
    {
        // compare if it is the same or not
        int8_t dif = BITCOUNT[t1->binary[i]] - BITCOUNT[t2->binary[i]];
        cmp_val += dif < 0 ? -dif : dif;
    }
    // return the computed compare value
    return cmp_val;
}

uint8_t compare_tile_px(const struct Tile *t1, const struct Tile *t2)
{
    // init cmp_val
    uint8_t cmp_val = 0;
    // for each pixels
    for (int y = 0; y < TILE_H; y++)
        for (int x = 0; x < TILE_W; x++)
            // compare if it is the same or not
            cmp_val += t1->pixels[y][x] != t2->pixels[y][x];
    // return the computed compare value
    return cmp_val;
}

void compare_tiles(
    const struct Tile tile_list[MAX_TILES],
    const struct Tile *tile,
    uint8_t compare_value[MAX_TILES],
    int *argmin,
    int *first_free,
    int *free_count)
{
    // init first_same & first_free
    *argmin = 0;
    *first_free = -1;
    *free_count = 0;

    // create empty tile and compare it to the tile
    struct Tile empty_tile;
    empty_tile.type = TILE_TYPE_FREE;
    for (int i = 0; i < TILE_BIN_SIZE; i++)
        empty_tile.binary[i] = 0;
    tile_bin2pix(&empty_tile);
    uint8_t free_cmp_val = compare_tile_px(&empty_tile, tile);

    // for each tile
    // struct Tile t = tile_list[0];
    for (int i = 0; i < MAX_TILES; i++)
    {
        struct Tile t = tile_list[i];
        // if tile is free
        if (t.type == TILE_TYPE_FREE)
        {
            // update first_free if needed
            if (*first_free < 0)
                *first_free = i;
            // update the compare value array
            // with the already computed value
            compare_value[i] = free_cmp_val;
            (*free_count)++;
        }
        else
        {
            // compare it with the alone tile
            // and update the compare value array
            compare_value[i] = compare_tile_px(&t, tile);
        }
        // update argmin if needed
        if (compare_value[i] < compare_value[*argmin])
            *argmin = i;
    }
}

uint8_t count_pixels(const struct Tile *t)
{
    // init cmp_val
    uint8_t sum = 0;
    // for each pixels
    for (int y = 0; y < TILE_H; y++)
        for (int x = 0; x < TILE_W; x++)
            // compare if it is the same or not
            sum += t->pixels[y][x] > 0;
    // return the computed compare value
    return sum;
}
