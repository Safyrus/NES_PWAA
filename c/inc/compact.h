#ifndef COMAPCT_H
#define COMAPCT_H

#include <stdint.h>

#include "tile.h"
#include "snif.h"

#define MAX_FILENAME_LEN 512

#define FILETYPE_CHR 0
#define FILETYPE_SNIF 1

/*
TODO
*/
int replace_bkg_tile(uint8_t *tile_cmp_matrix, struct Tile tile_list[MAX_TILES], const struct Tile *tile, uint8_t compare_value[MAX_TILES], int argmin);

/*
Description:
  add the `tile` to the `tile_list` if free space is availible or make space using the `tile_cmp_matrix`.
  In both case, `tile_cmp_matrix` is updated.

Arguments:
  - `tile_list`: a list of tiles.
  - `tile`: the tile to add to `tile_list`.
  - `tile_cmp_matrix`: the matrix containing compare values between every tiles in `tile_list`.

Return:
  The index where the `tile` was added.
*/
int add_bkg_tile(uint8_t *tile_cmp_matrix, struct Tile tile_list[MAX_TILES], const struct Tile *tile);

/*
TODO
*/
int read_chrfile_tiles(const char *filename, struct Tile tile_list[MAX_TILES]);

/*
TODO
*/
int read_sniffile_tiles(const char *filename, struct Tile tile_list[MAX_TILES], struct SNIFFile *snif);

/*
TODO and move elswhere
*/
int strendwith(const char *str, const char *end);

/*
TODO
*/
void merge_snif_tiles(const char *in_snif_folder, const char *in_chr_file, int n_res_tile, const char *out_snif_folder, const char *out_chr_file, int verbose);

#endif