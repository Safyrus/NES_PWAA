#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "compact.h"
#include "file_utils.h"
#include "utils.h"

uint8_t count_banks(const struct SNIFFile *snif, const uint16_t spr_idxs[], uint8_t banks[])
{
    uint8_t n_bank = 0;
    for (int i = 0; i < snif->n_spr; i++)
    {
        if (!spr_idxs[i])
            continue;
        uint8_t b = spr_idxs[i] >> 5;
        uint8_t is_in = 0;
        for (int j = 0; j < n_bank; j++)
            if (b == banks[j])
            {
                is_in = 1;
                break;
            }
        if (is_in)
            continue;
        banks[n_bank] = b;
        n_bank++;
    }
    return n_bank;
}

void merge_one_spr(uint8_t *tile_cmp_matrix, struct Tile *tile_list, struct SNIFFile *snif)
{
    // find where to put sprite tiles
    uint16_t spr_idxs[snif->n_spr];
    uint8_t spr_flips[snif->n_spr];
    for (int i = 0; i < snif->n_spr; i++)
    {
        int s_idx = (snif->ppu_banks[(snif->spr_data[i].t >> 5)] << 5) + (snif->spr_data[i].t & 0x1F);
        struct Tile *tile_lo = &snif->chr_data[s_idx * 2 + 0];
        struct Tile *tile_hi = &snif->chr_data[s_idx * 2 + 1];
        spr_idxs[i] = add_spr_tile(tile_cmp_matrix, tile_list, tile_lo, tile_hi, &spr_flips[i]);
    }
    // while bank > 8
    uint8_t banks[snif->n_spr];
    uint8_t n_bank = count_banks(snif, spr_idxs, banks);
    while (n_bank > 8)
    {
        // count pixels per bank
        // and take the bank with least pixels
        int min_px_val = 100000;
        uint8_t bank_to_remove = 0;
        int banks_px[snif->n_spr];
        for (size_t j = 0; j < n_bank; j++)
        {
            // count pixels in bank
            for (size_t i = 0; i < snif->n_spr; i++)
            {
                // if sprite in current bank
                uint8_t b = spr_idxs[i] >> 5;
                if (b == banks[j])
                {
                    uint8_t px = count_pixels(&tile_list[spr_idxs[i] * 2]);
                    px += count_pixels(&tile_list[spr_idxs[i] * 2 + 1]);
                    banks_px[j] += px;
                }
            }
            // keep if better
            if (banks_px[j] < min_px_val)
            {
                min_px_val = banks_px[j];
                bank_to_remove = j;
            }
        }
        // remove this bank
        for (int i = 0; i < snif->n_spr; i++)
        {
            // if not in bank to remove or an empty sprite then skip
            uint8_t b = spr_idxs[i] >> 5;
            if (b != banks[bank_to_remove] || !spr_idxs[i])
                continue;
            // remove the sprite
            tile_list[spr_idxs[i] * 2 + 0].type &= (unsigned)~TILE_TYPE_MASK_REPLACE;
            tile_list[spr_idxs[i] * 2 + 1].type &= (unsigned)~TILE_TYPE_MASK_REPLACE;
            spr_idxs[i] = 0;
        }
        // recount number of banks
        n_bank = count_banks(snif, spr_idxs, banks);
    }
    // apply sprite change
    uint8_t n_spr = 0;
    for (int i = 0; i < snif->n_spr; i++)
    {
        if (!spr_idxs[i])
            continue;
        // update tile in tile_list
        if (tile_list[spr_idxs[i] * 2].type & TILE_TYPE_MASK_REPLACE)
        {
            // replace tiles
            int s_idx = (snif->ppu_banks[(snif->spr_data[i].t >> 5)] << 5) + (snif->spr_data[i].t & 0x1F);
            tile_list[spr_idxs[i] * 2 + 0] = snif->chr_data[s_idx * 2 + 0];
            tile_list[spr_idxs[i] * 2 + 1] = snif->chr_data[s_idx * 2 + 1];
            // update compare_value
            for (int f = 0; f < 4; f++)
            {
                uint8_t compare_value[MAX_TILES];
                int tmp1;
                uint16_t tmp2;
                uint8_t tmp3;
                compare_spr_tiles(tile_list, &tile_list[spr_idxs[i] * 2 + 0], &tile_list[spr_idxs[i] * 2 + 1], compare_value, f, &tmp2, &tmp1, &tmp3);
                // replace row and column at old_tile_index by compare_value
                for (int j = 0; j < MAX_SPR_TILES; j++)
                {
                    int idx1 = f * (MAX_SPR_TILES * MAX_SPR_TILES) + spr_idxs[i] * MAX_SPR_TILES + j;
                    int idx2 = f * (MAX_SPR_TILES * MAX_SPR_TILES) + j * MAX_SPR_TILES + spr_idxs[i];
                    tile_cmp_matrix[idx1] = compare_value[j];
                    tile_cmp_matrix[idx2] = compare_value[j];
                }
            }
        }
        // update sprite data
        snif->spr_data[n_spr].h = spr_flips[i] & 0x01;
        snif->spr_data[n_spr].v = (spr_flips[i] >> 1) & 0x01;
        uint8_t b = spr_idxs[i] >> 5;
        uint8_t bnk_idx = 0;
        for (int j = 0; j < n_bank; j++)
            if (b == banks[j])
            {
                bnk_idx = j;
                break;
            }
        snif->spr_data[n_spr].t = (spr_idxs[i] & 0x1F) + (bnk_idx << 5);
        snif->spr_data[n_spr].pal = snif->spr_data[i].pal;
        snif->spr_data[n_spr].x = snif->spr_data[i].x;
        snif->spr_data[n_spr].y = snif->spr_data[i].y;
        n_spr++;
    }
    snif->n_spr = n_spr;
    // apply ppu bank change
    snif->ppu_mask = (1 << n_bank) - 1;
    for (int i = 0; i < n_bank; i++)
        snif->ppu_banks[i] = banks[i];
}

void merge_sprites(uint8_t *tile_cmp_matrix, struct Tile *tile_list, struct SNIFFile *snif, uint8_t img_type, const char *out_snif_folder, int verbose)
{
    // find each tmp snif file
    FILE *filelist = fopen_strict("tmp", "wb+");
    list_files(out_snif_folder, filelist, 1);
    rewind(filelist);
    // for each files
    while (1)
    {
        // get next filename and
        // stop if list of files is empty
        char filename[MAX_FILENAME_LEN];
        if (!read_line(filelist, filename, MAX_FILENAME_LEN))
            break;
        // skip if file is not a snif file
        if (!strendwith(filename, ".snif"))
        {
            // if (verbose)
            //     printf("\033[2K\rSNIF Merge (%d): skip non SNIF file '%s'", img_type, filename);
            continue;
        }
        // read SNIF file
        read_snif(filename, snif);
        //
        if (snif->img_type != img_type)
        {
            // if (verbose)
            //     printf("\033[2K\rSNIF Merge (%d): skip non wanted SNIF file '%s'", img_type, filename);
            continue;
        }
        // print info
        if (verbose)
        {
            int n_use_tiles = 0;
            for (int i = 0; i < MAX_TILES; i++)
                n_use_tiles += tile_list[i].type != TILE_TYPE_FREE ? 1 : 0;
            int percent_use = ((float)n_use_tiles / MAX_TILES) * 100;
            printf("\033[2K\rSNIF Merge (%d): merge SPR from '%s' (CHR usage: %d%%)", img_type, filename, percent_use);
        }
        //
        merge_one_spr(tile_cmp_matrix, tile_list, snif);
        // write temporary 'snif' file
        write_snif(filename, snif);
    }
    fclose(filelist);
    if (verbose)
        printf("\033[2K\rSNIF Merge (%d): merged all SPR tiles\n", img_type);
}

void merge_snif_tiles(const char *in_snif_folder, const char *in_chr_file, int n_res_tile, const char *out_snif_folder, const char *out_chr_file, int verbose, int region)
{
    ////////////////////////////////
    // init variables
    ////////////////////////////////
    if (verbose)
        printf("SNIF Merge: init\n");
    // declare variables
    uint8_t *tile_cmp_matrix = malloc(sizeof(uint8_t) * MAX_TILES * MAX_TILES);
    struct Tile *tile_list = malloc(sizeof(struct Tile) * MAX_TILES);
    struct Tile *new_tile_list = malloc(sizeof(struct Tile) * MAX_TILES);
    struct SNIFFile *snif = malloc(sizeof(struct SNIFFile));
    if (!tile_cmp_matrix || !tile_list || !new_tile_list || !snif)
    {
        fprintf(stderr, "Error (merge_snif_tiles): can't malloc\n");
        exit(1);
    }
    int new_tile_list_size;
    // init to default values
    init_tiles(tile_list, tile_cmp_matrix);

    ////////////////////////////////
    // add tiles from CHR
    ////////////////////////////////
    if (verbose)
        printf("SNIF Merge: add CHR file\n");
    // read tile from CHR file
    new_tile_list_size = read_chrfile_tiles(in_chr_file, new_tile_list);
    if (verbose)
        printf("SNIF Merge: CHR size in tiles: %d\n", new_tile_list_size);
    if (n_res_tile < 0)
        n_res_tile = new_tile_list_size;
    if (n_res_tile > new_tile_list_size)
    {
        fprintf(stderr, "Error (merge_snif_tiles): number of reserved tile (%d) is bigger than the number of tile in CHR (%d)", n_res_tile, new_tile_list_size);
        exit(1);
    }
    // reserved first n tiles
    for (int i = 0; i < n_res_tile; i++)
        new_tile_list[i].type = TILE_TYPE_RES;
    // add tiles to tile list
    for (int i = 0; i < new_tile_list_size; i++)
    {
        uint8_t type = new_tile_list[i].type;
        new_tile_list[i].type = TILE_TYPE_RES;
        int idx = add_bkg_tile(tile_cmp_matrix, tile_list, &new_tile_list[i]);
        tile_list[idx].type = type;
    }
    for (int i = 0; i < new_tile_list_size; i++)
        if (tile_list[i].type == TILE_TYPE_TMPRES)
            tile_list[i].type = TILE_TYPE_FREE;

    ////////////////////////////////
    // add BKG tiles from SNIF
    ////////////////////////////////
    if (verbose)
        printf("SNIF Merge: add SNIF files\n");
    // list all files in the snif dir into a temporary file
    FILE *filelist = fopen_strict("tmp", "wb+");
    list_files(in_snif_folder, filelist, 1);
    rewind(filelist);
    // for each files
    while (1)
    {
        // get next filename and
        // stop if list of files is empty
        char filename[MAX_FILENAME_LEN];
        if (!read_line(filelist, filename, MAX_FILENAME_LEN))
            break;
        // skip if file is not a snif file
        if (!strendwith(filename, ".snif"))
        {
            if (verbose)
                printf("\033[2KSNIF Merge: skip non SNIF file '%s'\n", filename);
            continue;
        }
        if (verbose)
        {
            int n_use_tiles = 0;
            for (int i = 0; i < MAX_TILES; i++)
                n_use_tiles += tile_list[i].type != TILE_TYPE_FREE ? 1 : 0;
            int percent_use = ((float)n_use_tiles / MAX_TILES) * 100;
            printf("\033[2K\rSNIF Merge: merge BKG from '%s' (CHR usage: %d%%)", filename, percent_use);
        }
        // read SNIF file
        new_tile_list_size = read_sniffile_tiles(filename, new_tile_list, snif);
        // add tiles to region
        for (int i = 0; i < new_tile_list_size; i++)
        {
            // skip non-tile
            if ((snif->bkg_data[i] & 0x3FFF) == 0)
                continue;
            // add the tile and get its new index
            int idx = add_bkg_tile(tile_cmp_matrix, tile_list, &new_tile_list[i]);
            // if tile return was the non-tile (idx 0)
            if (!idx)
                // change it to the empty tile (idx 1)
                idx++;
            // replace old index
            snif->bkg_data[i] = (snif->bkg_data[i] & 0xC000) | idx;
        }
        // get temporary 'snif' file name
        char outname[MAX_FILENAME_LEN];
        strcpy(outname, out_snif_folder);
        int outfolder_len = strlen(out_snif_folder);
        int infolder_len = strlen(in_snif_folder);
        if (outname[outfolder_len - 1] != SEP)
            outname[outfolder_len++] = SEP;
        if (filename[infolder_len - 1] == SEP)
            strcpy(&outname[outfolder_len], &filename[infolder_len]);
        else
            strcpy(&outname[outfolder_len], &filename[infolder_len + 1]);
        // write temporary 'snif' file
        snif->is_rleinc = 1;
        snif->r = region;
        mkdir_rec(outname, 0);
        write_snif(outname, snif);
    }
    if (verbose)
        printf("\033[2K\rSNIF Merge: merged all BKG tiles\n");
    fclose(filelist);

    ////////////////////////////////
    // add SPR tiles from SNIF
    ////////////////////////////////
    if (verbose)
        printf("SNIF Merge: Prepare SPR merging...\n");
    // compute tile_cmp_matrix but for sprites
    for (int flip = 0; flip < 4; flip++)
        for (int i = 0; i < MAX_SPR_TILES; i++)
        {
            struct Tile *tile_lo = &tile_list[i * 2 + 0];
            struct Tile *tile_hi = &tile_list[i * 2 + 1];
            uint8_t compare_values[MAX_SPR_TILES];
            int tmp1;
            uint8_t tmp3;
            uint16_t tmp2;
            compare_spr_tiles(tile_list, tile_lo, tile_hi, compare_values, flip, &tmp2, &tmp1, &tmp3);
            for (int j = 0; j < MAX_SPR_TILES; j++)
            {
                int idx = flip * (MAX_SPR_TILES * MAX_SPR_TILES) + i * MAX_SPR_TILES + j;
                tile_cmp_matrix[idx] = compare_values[j];
            }
        }
    //
    merge_sprites(tile_cmp_matrix, tile_list, snif, IMG_TYPE_BKG, out_snif_folder, verbose);
    merge_sprites(tile_cmp_matrix, tile_list, snif, IMG_TYPE_PHT, out_snif_folder, verbose);
    merge_sprites(tile_cmp_matrix, tile_list, snif, IMG_TYPE_CHR, out_snif_folder, verbose);
    //
    // find each tmp snif file
    filelist = fopen_strict("tmp", "wb+");
    list_files(out_snif_folder, filelist, 1);
    rewind(filelist);
    // for each files
    while (1)
    {
        // get next filename and
        // stop if list of files is empty
        char filename[MAX_FILENAME_LEN];
        if (!read_line(filelist, filename, MAX_FILENAME_LEN))
            break;
        // skip if file is not a snif file
        if (!strendwith(filename, ".snif"))
        {
            // if (verbose)
            //     printf("\033[2K\rSNIF Merge: skip non SNIF file '%s'", filename);
            continue;
        }
        // read SNIF file
        read_snif(filename, snif);
        // print info
        if (verbose)
            printf("\033[2K\rSNIF Merge: ouput '%s'", filename);
        // change metadata to only be an empty hash
        snif->metadata_len = HASH_SIZE;
        for (int i = 0; i < HASH_SIZE; i++)
            snif->metadata[i] = 0;
        // write temporary 'snif' file without CHR tiles
        snif->n_chr_tile = 0;
        snif->is_rleinc = 1;
        write_snif(filename, snif);
        // compute hash from file
        uint64_t h = hash_file(filename);
        // update hash of snif file
        FILE *f = fopen(filename, "rb+");
        for (int i = 0; i < HASH_SIZE; i++)
            write_byte_strict(f, (h >> (i * 8)) & 0xFF);
        fclose(f);

        // // find image hash
        // char hash[HASH_SIZE + 1];
        // const char wanted_str[] = "hashori\":\"";
        // for (int i = 0; i < snif->metadata_len; i++)
        // {
        //     int j = 0;
        //     int find = 1;
        //     while (wanted_str[j])
        //     {
        //         if (wanted_str[j] != snif->metadata[i + j])
        //         {
        //             find = 0;
        //             break;
        //         }
        //         j++;
        //     }
        //     if (find)
        //     {
        //         strncpy(hash, &snif->metadata[i + j], HASH_SIZE);
        //         hash[64] = 0;
        //         break;
        //     }
        // }
        // // change metadata to only be the hash value
        // snif->metadata_len = HASH_SIZE;
        // strcpy(snif->metadata, hash);
        // // write temporary 'snif' file without CHR tiles
        // snif->n_chr_tile = 0;
        // snif->is_rleinc = 1;
        // write_snif(filename, snif);
    }
    fclose(filelist);
    if (verbose)
        printf("\033[2K\rSNIF Merge: outputed all images\n");

    ////////////////////////////////
    // write CHR region
    ////////////////////////////////
    // open file
    FILE *outchr_file = fopen_strict(out_chr_file, "wb");
    // write tiles
    for (int i = 0; i < MAX_TILES; i++)
        for (int j = 0; j < TILE_BIN_SIZE; j++)
            write_byte_strict(outchr_file, tile_list[i].binary[j]);
    // close file
    fclose(outchr_file);

    ////////////////////////////////
    // Free resources
    ////////////////////////////////
    if (verbose)
        printf("SNIF Merge: free memory\n");
    free(tile_cmp_matrix);
    free(tile_list);
    free(new_tile_list);
    free(snif);

    if (verbose)
        printf("SNIF Merge: done\n");
    return;
}
