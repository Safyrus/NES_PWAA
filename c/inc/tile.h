#ifndef TILE_HEADER
#define TILE_HEADER

#include <stdint.h>

#define TILE_H 8
#define TILE_W 8
#define TILE_BIN_SIZE 16

#define MAX_TILES 16384

enum TILE_TYPE
{
    TILE_TYPE_FREE = 0,
    TILE_TYPE_RES,
    TILE_TYPE_NORMAL,
    TILE_TYPE_TMPRES,
};

struct Tile
{
    char pixels[TILE_H][TILE_W]; // the pixels of the tile
    uint8_t binary[TILE_BIN_SIZE];  // the binary format of the tile
    char type;                   // a value of TILE_TYPE
};

extern const uint8_t BITCOUNT[256];

/*
TODO
*/
void tile_bin2pix(struct Tile *tile);

/*
Description:
  Compare 2 tiles and return a value representing the difference between them.
  The value is based on the number of different pixels.

Argument:
  - `t1`: the first tile
  - `t2`: the second tile

Return:
  The value representing the difference between them.
  The higher the value, the more different they are.
  The value is positive.
  A value of 0 indicate that the 2 tiles are identical.
*/
uint8_t compare_tile_px(const struct Tile *t1, const struct Tile *t2);

/*
Description:
  Compare 2 tiles and return a value representing the difference between them.
  The value is based on the number of different bits.

Argument:
  - `t1`: the first tile
  - `t2`: the second tile

Return:
  The value representing the difference between them.
  The higher the value, the more different they are.
  The value is positive.
  A value of 0 indicate that the 2 tiles are identical.
*/
uint8_t compare_tile_bin(const struct Tile *t1, const struct Tile *t2);

/*
Description:
  Compare a `tile` to a list of tiles `tile_list`.

Arguments:
  - `tile`: The tile to compare
  - `tile_list`: The list of tiles to compare against `tile`

Returns:
  - `compare_value`: Compare values for each tile in `tile_list` compare against `tile`
  - `argmin`: The index with the minimum value
  - `first_free`: The first index of the tile in `tile_list` that is free
*/
void compare_tiles(const struct Tile tile_list[MAX_TILES], const struct Tile *tile, uint8_t compare_value[MAX_TILES], int *argmin, int *first_free);

#endif