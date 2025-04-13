#ifndef SNIF_H
#define SNIF_H

#include "tile.h"

#define SNIF_MAX_METADATA_LEN 1024
#define SNIF_MAX_TILE 1024
#define SNIF_MAX_SPR 64
#define SNIF_MAX_CHR 16 * 1024

#define SPRCMD_END 0x00
#define SPRCMD_FLIP 0x04
#define SPRCMD_PAL 0x08
#define SPRCMD_POS 0x0C

struct Sprite
{
    char x;
    char y;
    char t;
    char pal;
    char h;
    char v;
};

struct SNIFFile
{
    char metadata[SNIF_MAX_METADATA_LEN];
    int metadata_len;
    char w;
    char h;
    char r;
    char is_rleinc;
    char pal_drop;
    char pals[8][3];
    uint8_t ppu_mask;
    char ppu_banks[8];
    uint16_t bkg_data[SNIF_MAX_TILE];
    uint16_t bkg_data_len_lo;
    uint16_t bkg_data_len_hi;
    struct Sprite spr_data[SNIF_MAX_SPR];
    struct Tile chr_data[SNIF_MAX_CHR];
    uint8_t n_spr;
    uint16_t n_chr_tile;
};

void print_snif(struct SNIFFile *snif);
void read_snif(const char *filename, struct SNIFFile *snif);
void write_snif(const char *filename, struct SNIFFile *snif);

#endif