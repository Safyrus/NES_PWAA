#include <time.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "rle_inc.h"

#define TILE_SIZE 64
#define TILE_ROW_SIZE 8
#define BANK_SIZE 256 * 256
#define TILE_PER_BANK_PAGE 256
#define CHR_TILE_SIZE 16
#define IMG_SIZE 256 * 3
#define ROM_SIZE 1024 * 1024

uint8_t tile_dif(uint8_t t1[TILE_SIZE], uint8_t t2[TILE_SIZE], uint8_t MAX_PIX_DIF)
{
    uint8_t dif = 0;
    for (uint8_t i = 0; i < TILE_SIZE; i++)
    {
        dif += t1[i] != t2[i];
        if (dif > MAX_PIX_DIF)
            return dif;
    }
    return dif;
}

int closest_tile(uint8_t tile[TILE_SIZE], uint8_t bank[BANK_SIZE][TILE_SIZE], int bank_len, uint8_t MAX_PIX_DIF)
{
    int idx = -1;
    uint8_t best = MAX_PIX_DIF + 1;
    for (int i = 0; i < bank_len; i++)
    {
        uint8_t dif = tile_dif(tile, bank[i], MAX_PIX_DIF);
        if (dif == 0)
            return i;
        if (dif < best)
        {
            best = dif;
            idx = i;
        }
    }
    return idx;
}

void add_tile(uint8_t tile[TILE_SIZE], uint8_t bank[BANK_SIZE][TILE_SIZE], int idx)
{
    if (idx >= BANK_SIZE)
    {
        printf("\e[31m[ERROR]:\e[0m out of bank ! number of tiles (%d) > bank length (%d)\n", idx + 1, BANK_SIZE);
        exit(1);
    }
    for (int i = 0; i < TILE_SIZE; i++)
        bank[idx][i] = tile[i];
}

void tile2chr(uint8_t tile[TILE_SIZE], uint8_t chr[CHR_TILE_SIZE])
{
    uint8_t idx = 0;
    for (uint8_t y = 0; y < TILE_ROW_SIZE; y++)
    {
        uint8_t b = 0;
        for (uint8_t x = 0; x < TILE_ROW_SIZE; x++)
            b |= (tile[y * TILE_ROW_SIZE + x] & 1) << (TILE_ROW_SIZE - 1 - x);
        chr[idx] = b;
        idx++;
    }

    for (uint8_t y = 0; y < TILE_ROW_SIZE; y++)
    {
        uint8_t b = 0;
        for (uint8_t x = 0; x < TILE_ROW_SIZE; x++)
            b |= ((tile[y * TILE_ROW_SIZE + x] & 2) >> 1) << (TILE_ROW_SIZE - 1 - x);
        chr[idx] = b;
        idx++;
    }
}

FILE *open(char *name, char *mode)
{
    FILE *f;
    f = fopen(name, mode);
    if (f == NULL)
    {
        printf("\e[31m[ERROR]:\e[0m can't open %s\n", name);
        exit(1);
    }
    return f;
}

void load_img(char *img_path, uint8_t img[IMG_SIZE][TILE_SIZE])
{
    FILE *f = open(img_path, "rb");
    fread(img, TILE_SIZE, IMG_SIZE, f);
    fclose(f);
}

void verify_img(uint8_t img[IMG_SIZE][TILE_SIZE])
{
    for (int i = 0; i < IMG_SIZE; i++)
        for (int k = 0; k < TILE_SIZE; k++)
            if (img[i][k] > 3)
            {
                printf("\e[31m[ERROR]:\e[0m Image have more than 4 colors\n");
                exit(1);
            }
}

void save_map(char *img_path, uint16_t map[IMG_SIZE])
{
    FILE *f = open(img_path, "wb");
    fwrite(map, IMG_SIZE*2, 1, f);
    fclose(f);
}

uint8_t tile_bank[BANK_SIZE][TILE_SIZE];
uint8_t img[IMG_SIZE][TILE_SIZE];
uint16_t img_map[IMG_SIZE];
uint8_t chr_bank[BANK_SIZE][CHR_TILE_SIZE];
uint8_t rom[ROM_SIZE];
struct timespec start, stop;

int main(int argc, char const *argv[])
{
    if (argc <= 1)
    {
        printf("args: <file_count> [chr_path] [MAX_PIX_DIF]\n");
        return 1;
    }

    srand(time(NULL));

    int bank_len = 4;
    int nb_img = atoi(argv[1]);
    char chr_path[64];
    strcpy(chr_path, "out.chr");
    if (argc > 2)
        strcpy(chr_path, argv[2]);
    uint8_t MAX_PIX_DIF = 0;
    if (argc > 3)
        MAX_PIX_DIF = atoi(argv[3]);

    printf("init bank\n");
    for (int i = 0; i < bank_len; i++)
        for (int j = 0; j < TILE_SIZE; j++)
            tile_bank[i][j] = i;

    printf("start converting image to tiles\n");
    printf("0/%d | time: 0 sec\n", nb_img);
    clock_gettime(CLOCK_REALTIME, &start);
    for (int j = 0; j < nb_img; j++)
    {
        // open image file
        char img_path[32];
        sprintf(img_path, "imgs/%d.bin", j);
        load_img(img_path, img);
        // exit if file is not correct
        verify_img(img);

        // for all tiles
        for (int i = 0; i < IMG_SIZE; i++)
        {
            // find closest tile
            int idx = closest_tile(img[i], tile_bank, bank_len, MAX_PIX_DIF);
            // if tile not found
            if (idx < 0)
            {
                add_tile(img[i], tile_bank, bank_len);
                idx = bank_len;
                bank_len++;
            }
            // update tile map
            img_map[i] = idx;
        }

        // save tile map
        sprintf(img_path, "maps/%d.bin", j);
        save_map(img_path, img_map);

        // print info
        clock_gettime(CLOCK_REALTIME, &stop);
        double accum = (stop.tv_sec - start.tv_sec) + (double)(stop.tv_nsec - start.tv_nsec) / (double)1000000000L;
        printf("\e[A\e[2K\r%d/%d | bnk_len : %d | time: %lf sec\n", j + 1, nb_img, bank_len, accum);
    }

    printf("convert tile to CHR\n");
    for (int i = 0; i < bank_len; i++)
        tile2chr(tile_bank[i], chr_bank[i]);

    printf("write CHR file\n");
    FILE *chr = open(chr_path, "wb");
    int file_size = (((bank_len / TILE_PER_BANK_PAGE) + 1) * TILE_PER_BANK_PAGE) * CHR_TILE_SIZE;
    fwrite(&chr_bank, file_size, 1, chr);
    fclose(chr);

    printf("done\n");
    return 0;
}
