#include <time.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "compact.h"
#include "file_utils.h"
#include "tile.h"
#include "snif.h"

int read_chrfile_tiles(const char *filename, struct Tile tile_list[MAX_TILES])
{
    // skip empty file
    if (!filename[0])
        return 0;

    // open the file
    FILE *file = fopen_strict(filename, "rb");

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

    // get number of tiles
    int n_tile = snif->bkg_data_len_lo;
    if (n_tile < snif->bkg_data_len_hi)
        n_tile = snif->bkg_data_len_hi;

    // copy CHR tiles
    for (int i = 0; i < n_tile; i++)
    {
        uint16_t tile_idx = snif->bkg_data[i] & 0x3FFF;
        tile_list[i] = snif->chr_data[tile_idx];
    }

    // return list size
    return n_tile;
}

void init_tiles(struct Tile *tile_list, uint8_t *tile_cmp_matrix)
{
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
}

int main(int argc, char const *argv[])
{
    if (argc <= 6)
    {
        printf("args: <input snif folder> <input chr file> <input empty chr file> <n reserved tiles> <outchr file> <asm data folder>\n");
        return 1;
    }

    srand(time(NULL));

    int n_res = atoi(argv[4]);
    int len = strlen(argv[1]);
    char path[len + 4];
    // char null_path[] = "";

    // recreate out folder
    rmdir_rec("out", 1);
    char tmp[5] = "out\0";
    tmp[3] = SEP;
    mkdir_rec(tmp, 0);
    // merge file from r0
    strcpy(path, argv[1]);
    join_path(path, "r0");
    printf("Merge file from r0\n");
    merge_snif_tiles(path, argv[2], n_res, "out/r0", "out/r0.chr", 1, 0);
    // merge file from r1
    path[len] = 0;
    join_path(path, "r1");
    printf("Merge file from r1\n");
    merge_snif_tiles(path, argv[3], 2, "out/r1", "out/r1.chr", 1, 1);
    // merge file from r2
    path[len] = 0;
    join_path(path, "r2");
    printf("Merge file from r2\n");
    merge_snif_tiles(path, argv[3], 2, "out/r2", "out/r2.chr", 1, 2);
    // merge file from r3
    path[len] = 0;
    join_path(path, "r3");
    printf("Merge file from r3\n");
    merge_snif_tiles(path, argv[3], 2, "out/r3", "out/r3.chr", 1, 3);
    // output asm files
    printf("Output to ASM\n");
    asm_snif(argv[5], argv[6], "out");
    printf("finished\n");

    return 0;
}
