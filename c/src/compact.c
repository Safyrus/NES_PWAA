#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <direct.h>

#include "compact.h"
#include "snif.h"
#include "file_utils.h"

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
    int argmin, first_free;
    compare_tiles(tile_list, tile, compare_value, &argmin, &first_free);

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

    // if a tile as a compare value of 0
    if (compare_value[argmin] == 0)
    {
        // then the tile is already in the list
        // and we return this index
        return argmin;
    }

    // else, if there is a free tile in the list
    if (first_free >= 0)
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

int read_chrfile_tiles(const char *filename, struct Tile tile_list[MAX_TILES])
{
    // open the file
    FILE *file = fopen(filename, "rb");
    if (!file)
    {
        fprintf(stderr, "Error (read_chrfile_tiles): cannot read CHR file '%s'\n", filename);
        exit(1);
    }

    // read file for tiles
    int list_size = 0;
    while (list_size < MAX_TILES && fread(tile_list[list_size].binary, TILE_BIN_SIZE, 1, file) == 1)
    {
        // convert binary data to pixels
        tile_bin2pix(&tile_list[list_size]);
        // count non 0 pixels
        int n_zero_pix = 0;
        for (int y = 0; y < TILE_H; y++)
            for (int x = 0; x < TILE_W; x++)
                n_zero_pix += tile_list[list_size].pixels[y][x];

        // set correct type based on non 0 pixels count
        if (n_zero_pix == 0)
            tile_list[list_size].type = TILE_TYPE_TMPRES;
        else
            tile_list[list_size].type = TILE_TYPE_RES;
        // next
        list_size++;
    }

    // close file and return tile list size
    fclose(file);
    return list_size;
}

int read_sniffile_tiles(const char *filename, struct Tile tile_list[MAX_TILES], struct SNIFFile *snif)
{
    /*
    read SNIF file
    /!\ Assumptions /!\
    - only 1 image
    */
    read_snif(filename, snif);

    // check if CHR data >= w*h
    int n_tile = snif->w * snif->h;
    if (snif->n_chr_tile < snif->w + snif->h)
    {
        fprintf(stderr, "Error (read_sniffile_tiles): not enought CHR data in SNIF file '%s'\n", filename);
        exit(1);
    }

    // copy CHR tiles
    for (int i = 0; i < n_tile; i++)
    {
        uint16_t tile_idx = snif->bkg_data[i] & 0x3FFF;
        tile_list[i] = snif->chr_data[tile_idx];
    }

    // return list size
    return n_tile;
}

int strendwith(const char *str, const char *end)
{
    if (!str || !end)
        return 0;
    size_t str_len = strlen(str);
    size_t end_len = strlen(end);
    if (end_len > str_len)
        return 0;
    return strncmp(str + str_len - end_len, end, end_len) == 0;
}

void merge_snif_tiles(const char *in_snif_folder, const char *in_chr_file, int n_res_tile, const char *out_snif_folder, const char *out_chr_file, int verbose)
{
    ////////////////////////////////
    // init variables
    ////////////////////////////////
    if (verbose)
        printf("SNIF Merge: init\n");
    // declare variables
    uint8_t *tile_cmp_matrix = malloc(sizeof(uint8_t) * MAX_TILES * MAX_TILES);
    if (!tile_cmp_matrix)
    {
        fprintf(stderr, "Error (merge_snif_tiles): can't malloc\n");
        exit(1);
    }
    struct Tile *tile_list = malloc(sizeof(struct Tile) * MAX_TILES);
    if (!tile_list)
    {
        fprintf(stderr, "Error (merge_snif_tiles): can't malloc\n");
        exit(1);
    }
    struct Tile *new_tile_list = malloc(sizeof(struct Tile) * MAX_TILES);
    if (!new_tile_list)
    {
        fprintf(stderr, "Error (merge_snif_tiles): can't malloc\n");
        exit(1);
    }
    struct SNIFFile *snif = malloc(sizeof(struct SNIFFile));
    if (!snif)
    {
        fprintf(stderr, "Error (merge_snif_tiles): can't malloc\n");
        exit(1);
    }
    int new_tile_list_size;
    // init to default values
    for (int i = 0; i < MAX_TILES; i++)
    {
        // init tiles binary
        for (int j = 0; j < TILE_BIN_SIZE; j++)
            tile_list[i].binary[j] = 0;
        // init tiles pixels
        for (int y = 0; y < TILE_H; y++)
            for (int x = 0; x < TILE_W; x++)
                tile_list[i].pixels[y][x] = 0;
        // init tiles type
        tile_list[i].type = TILE_TYPE_FREE;
        // init tile_cmp_matrix
        for (int j = 0; j < MAX_TILES; j++)
            tile_cmp_matrix[i * MAX_TILES + j] = 0;
    }

    ////////////////////////////////
    // add tiles from CHR
    ////////////////////////////////
    if (verbose)
        printf("SNIF Merge: add CHR file\n");
    // read tile from CHR file
    new_tile_list_size = read_chrfile_tiles(in_chr_file, new_tile_list);
    if (verbose)
        printf("SNIF Merge: CHR size in tiles: %d\n", new_tile_list_size);
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
    // create temporary file
    FILE *filelist = fopen("tmp", "wb+");
    if (!filelist)
    {
        fprintf(stderr, "Error (merge_snif_tiles): cannot create tmp file\n");
        exit(1);
    }
    // find all files in the snif dir
    rewind(filelist);
    list_files(in_snif_folder, filelist, 1);
    // for each files
    rewind(filelist);
    int c = 0;
    while (1)
    {
        // stop if list of file empty
        if (c == EOF)
            break;
        // get next filename
        int i = 0;
        char filename[MAX_FILENAME_LEN];
        do
        {
            c = fgetc(filelist);
            filename[i] = c;
            i++;
        } while (c != EOF && c != '\n' && i < MAX_FILENAME_LEN);
        i--;
        filename[i] = 0;
        // skip if file is not a snif file
        if (!strendwith(filename, ".snif"))
        {
            if (verbose)
                printf("SNIF Merge: skip non SNIF file '%s'\n", filename);
            continue;
        }
        if (verbose)
        {
            int n_use_tiles = 0;
            for (int i = 0; i < MAX_TILES; i++)
                n_use_tiles += tile_list[i].type != TILE_TYPE_FREE ? 1 : 0;
            int percent_use = ((float)n_use_tiles / MAX_TILES) * 100;
            printf("SNIF Merge: merge '%s' (CHR usage: %d%%) \n", filename, percent_use);
        }
        // read SNIF file
        new_tile_list_size = read_sniffile_tiles(filename, new_tile_list, snif);
        // add tiles to region
        for (int i = 0; i < new_tile_list_size; i++)
        {
            int idx = add_bkg_tile(tile_cmp_matrix, tile_list, &new_tile_list[i]);
            snif->bkg_data[i] = idx;
        }
        // write modified SNIF file
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
        mkdir_rec(outname, 0);
        write_snif(outname, snif);
    }

    ////////////////////////////////
    // write CHR region
    ////////////////////////////////
    // open file
    FILE *outchr_file = fopen(out_chr_file, "wb");
    if (!outchr_file)
    {
        fprintf(stderr, "Error (merge_snif_tiles): cannot write CHR file '%s'\n", out_chr_file);
        exit(1);
    }
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
    fclose(filelist);

    if (verbose)
        printf("SNIF Merge: done\n");
    return;
}

void asm_snif()
{
    // TODO
    // merge 4 CHR region into one CHR file
    // write img data
        // write in order bkg, anim & photo image data
        // write constant file
    // same for anim
}

int main(int argc, char const *argv[])
{
    if (argc <= 4)
    {
        printf("args: <input snif folder> <input chr file> <n reserved tiles> <output snif folder> <output chr file>\n");
        return 1;
    }

    int n_res = atoi(argv[3]);
    merge_snif_tiles(argv[1], argv[2], n_res, argv[4], argv[5], 1);
    asm_snif();

    return 0;
}
