#ifndef COMAPCT_H
#define COMAPCT_H

#include <stdint.h>

#include "meta_param.h"
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
TODO
*/
void merge_snif_tiles(const char *in_snif_folder, const char *in_chr_file, int n_res_tile, const char *out_snif_folder, const char *out_chr_file, int verbose, int region);

void init_tiles(struct Tile *tile_list, uint8_t *tile_cmp_matrix);

void merge_chrs(const char *final_chr);

int asm_snif_img_one(const char *filename, FILE *img_data, FILE *img_names, uint8_t *hash_list, int *index, int *size, int *ptr_adr, char img_type, int *anim_idx, int *anim_time, int *offset);

void asm_snif_img(const char *tmp_snif_dir, FILE *img_data, FILE *img_names, uint8_t *hash_list, int *index, int *size, int *ptr_adr, char img_type);

void asm_snif(const char *final_chr, const char *data_path, const char *tmp_snif_dir);

uint16_t replace_spr_tile(
    uint8_t *tile_cmp_matrix,
    struct Tile tile_list[MAX_TILES],
    uint8_t compare_value[4][MAX_SPR_TILES],
    uint16_t argmin,
    uint8_t *out_flip);

uint16_t add_spr_tile(
    uint8_t *tile_cmp_matrix,
    struct Tile tile_list[MAX_TILES],
    const struct Tile *tile_lo,
    const struct Tile *tile_hi,
    uint8_t *out_flip);

#endif