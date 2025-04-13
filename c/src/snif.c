#include <stdlib.h>
#include <stdio.h>

#include "snif.h"
#include "rle_inc.h"
#include "file_utils.h"

void print_snif(struct SNIFFile *snif)
{
    printf("size:%d*%d  region:%d  rleinc:%d\n", snif->w, snif->h, snif->r, snif->is_rleinc);
    printf("metadata (%d)%s:\n", snif->metadata_len, snif->metadata);
    printf("nb spr:%d  nb CHR tile:%d\n", snif->n_spr, snif->n_chr_tile);
    printf("palettes:   BKG  SPR\n");
    for (int i = 0; i < 4; i++)
    {
        printf("  [%02X,%02X,%02X,%02X]", snif->pal_drop, snif->pals[i][0], snif->pals[i][1], snif->pals[i][2]);
        printf("  [%02X,%02X,%02X,%02X]\n", snif->pal_drop, snif->pals[i + 4][0], snif->pals[i + 4][1], snif->pals[i + 4][2]);
    }
    printf("PPU Banks:");
    for (int i = 0; i < 8; i++)
        printf("%02X ", snif->ppu_banks[i]);
    printf("\n");
    printf("BKG Image (left=low  right=high):\n");
    for (int y = 0; y < snif->h; y++)
    {
        for (int x = 0; x < snif->w; x++)
        {
            char c = snif->bkg_data[y * snif->w + x] & 0xFF;
            if (c < 0x20 || c >= 0x7F)
                c = '.';
            printf("%c", c);
        }
        printf("  ");
        for (int x = 0; x < snif->w; x++)
        {
            char c = snif->bkg_data[y * snif->w + x] >> 8;
            if (c < 0x20 || c >= 0x7F)
                c = '.';
            printf("%c", c);
        }
        printf("\n");
    }
}

void read_snif(const char *filename, struct SNIFFile *snif)
{
    /*
    /!\ Assumptions /!\
    - have metadata and we don't care what they mean
    - no '}' in metadata
    - only 1 image is present
    */

    // open the file
    FILE *file = fopen(filename, "rb");
    if (!file)
    {
        fprintf(stderr, "Error (read_snif): cannot open SNIF file '%s'\n", filename);
    }

    ////////////////////////
    // read metadata
    ////////////////////////
    snif->metadata_len = 0;
    int c = 0;
    while (c != '}' && c != EOF && snif->metadata_len <= SNIF_MAX_METADATA_LEN)
    {
        c = read_byte_strict(file);
        snif->metadata[snif->metadata_len] = c;
        snif->metadata_len++;
    }
    if (snif->metadata_len > SNIF_MAX_METADATA_LEN)
    {
        fprintf(stderr, "Error (read_snif): metadata is too long in SNIF file '%s'\n", filename);
        exit(1);
    }
    if (c == EOF)
    {
        fprintf(stderr, "Error (read_snif): metadata in SNIF file '%s' does not end\n", filename);
        exit(1);
    }
    snif->metadata[snif->metadata_len] = 0;

    ////////////////////////
    // read first byte
    ////////////////////////
    char b = read_byte_strict(file);
    snif->w = (b & 0x1F) + 1;
    snif->r = (b & 0x60) >> 5;
    snif->is_rleinc = (b & 0x80) >> 7;
    ////////////////////////
    // read second byte
    ////////////////////////
    b = read_byte_strict(file);
    snif->h = (b & 0x1F) + 1;

    // error check
    if (snif->w * snif->h > SNIF_MAX_TILE)
    {
        fprintf(stderr, "Error (read_snif): image too big in SNIF file '%s' (can be at most %d tiles)\n", filename, SNIF_MAX_TILE);
        exit(1);
    }

    ////////////////////////
    // read palettes
    ////////////////////////
    b = read_byte_strict(file);
    char next = b & 0x80;
    snif->pal_drop = b & 0x3F;
    for (int i = 0; i < 8; i++)
    {
        snif->pals[i][0] = 0x3F;
        snif->pals[i][1] = 0x3F;
        snif->pals[i][2] = 0x3F;
    }
    while (next)
    {
        char b0 = read_byte_strict(file);
        char b1 = read_byte_strict(file);
        char b2 = read_byte_strict(file);

        next = b0 & 0x80;
        int idx = ((b1 & 0xC0) >> 6) + ((b0 & 0x40) >> 4);
        snif->pals[idx][0] = b0 & 0x3F;
        snif->pals[idx][1] = b1 & 0x3F;
        snif->pals[idx][2] = b2 & 0x3F;
    }

    ////////////////////////
    // read PPU CHR banks
    ////////////////////////
    b = read_byte_strict(file);
    for (int i = 0; i < 8; i++)
        snif->ppu_banks[i] = 0;
    snif->ppu_mask = b;
    for (int i = 0; i < BITCOUNT[snif->ppu_mask]; i++)
        snif->ppu_banks[i] = read_byte_strict(file);

    ////////////////////////
    // read BKG data
    ////////////////////////
    if (snif->is_rleinc)
    {
        // read low bytes
        uint8_t tmp_bkg_data[SNIF_MAX_TILE];
        rleinc_fdecode(file, tmp_bkg_data, &snif->bkg_data_len_lo);
        for (int i = 0; i < snif->bkg_data_len_lo; i++)
            snif->bkg_data[i] = tmp_bkg_data[i];
        // read high bytes
        rleinc_fdecode(file, tmp_bkg_data, &snif->bkg_data_len_hi);
        for (int i = 0; i < snif->bkg_data_len_hi; i++)
            snif->bkg_data[i] += tmp_bkg_data[i] << 8;
        }
    else
    {
        snif->bkg_data_len_lo = snif->w * snif->h;
        snif->bkg_data_len_hi = snif->w * snif->h;
        // read low bytes
        for (int i = 0; i < snif->bkg_data_len_lo; i++)
            snif->bkg_data[i] = read_byte_strict(file);
        // read high bytes
        for (int i = 0; i < snif->bkg_data_len_hi; i++)
            snif->bkg_data[i] += read_byte_strict(file) << 8;
    }

    ////////////////////////
    // read SPR data
    ////////////////////////
    char end = 0;
    snif->n_spr = 0;
    short cur_pos = 0;
    char cur_pal = 0;
    char cur_h_flip = 0;
    char cur_v_flip = 0;
    while (!end)
    {
        b = read_byte_strict(file);
        // if sprite
        if (b & 0x80)
        {
            char b1 = read_byte_strict(file);
            char y_offset = b & 0x0F;
            char x_offset = (b >> 4) & 0x07;
            snif->spr_data[snif->n_spr].x = (cur_pos % snif->w) * 8 + x_offset;
            snif->spr_data[snif->n_spr].y = ((cur_pos / snif->w) % snif->h) * 16 + y_offset;
            snif->spr_data[snif->n_spr].t = (b1 / 2) + (b1 % 2 ? 128 : 0);
            snif->spr_data[snif->n_spr].pal = cur_pal;
            snif->spr_data[snif->n_spr].h = cur_h_flip;
            snif->spr_data[snif->n_spr].v = cur_v_flip;
            snif->n_spr++;
            cur_pos += 1;
        }
        // or command
        else
        {
            b &= 0x7F;
            if (b == SPRCMD_END)
                end = 1;
            else if ((b & 0xFC) == SPRCMD_PAL)
                cur_pal = b & 0x03;
            else if ((b & 0xFC) == SPRCMD_POS)
            {
                char b1 = read_byte_strict(file);
                char x = (b & 0x01) << 4;
                char y = ((b >> 1) & 0x01) << 4;
                x += (b1 >> 4) & 0x0F;
                y += b1 & 0x0F;
                cur_pos = y * snif->w + x;
            }
            else if ((b & 0xFC) == SPRCMD_FLIP)
            {
                cur_h_flip = b & 0x01;
                cur_v_flip = (b >> 1) & 0x01;
            }
        }
    }

    ////////////////////////
    // read CHR data
    ////////////////////////
    snif->n_chr_tile = 0;
    while (fread(snif->chr_data[snif->n_chr_tile].binary, TILE_BIN_SIZE, 1, file) == 1)
    {
        // convert binary data to pixels
        tile_bin2pix(&snif->chr_data[snif->n_chr_tile]);
        // count non 0 pixels
        int n_zero_pix = 0;
        for (int y = 0; y < TILE_H; y++)
            for (int x = 0; x < TILE_W; x++)
                n_zero_pix += snif->chr_data[snif->n_chr_tile].pixels[y][x];
        // set correct type based on non 0 pixels count
        if (n_zero_pix == 0)
            snif->chr_data[snif->n_chr_tile].type = TILE_TYPE_FREE;
        else
            snif->chr_data[snif->n_chr_tile].type = TILE_TYPE_NORMAL;
        // next
        snif->n_chr_tile++;
    }
    // check for error if end of file was not reach
    if (!feof(file))
    {
        fprintf(stderr, "Error (read_snif): something went wrong when reading CHR data in SNIF file '%s'\n", filename);
        exit(1);
    }

    fclose(file);
}

void write_snif(const char *filename, struct SNIFFile *snif)
{
    /*
    /!\ Assumptions /!\
    - have metadata and we don't care what they mean
    - no '}' in metadata
    - only 1 image is present
    */

    // open the file
    FILE *file = fopen(filename, "wb");
    if (!file)
    {
        fprintf(stderr, "Error (write_snif): cannot open SNIF file '%s'\n", filename);
        exit(1);
    }

    ////////////////////////
    // write metadata
    ////////////////////////
    if (fwrite(snif->metadata, snif->metadata_len, 1, file) != 1)
    {
        fprintf(stderr, "Error (write_snif): cannot write metadata in SNIF file '%s'\n", filename);
        exit(1);
    }

    ////////////////////////
    // write byte 0
    ////////////////////////
    uint8_t b = (snif->w - 1) | (snif->is_rleinc << 7) | (snif->r << 5);
    write_byte_strict(file, b);
    ////////////////////////
    // write byte 1
    ////////////////////////
    write_byte_strict(file, snif->h - 1);

    ////////////////////////
    // write palettes
    ////////////////////////
    // find what palette is used
    uint8_t pal_mask = 0;
    for (int i = 0; i < 8; i++)
    {
        pal_mask >>= 1;
        for (int j = 0; j < 3; j++)
        {
            if (snif->pals[i][j] != 0x3F)
            {
                pal_mask |= 0x80;
                break;
            }
        }
    }
    // write palette drop
    b = snif->pal_drop + ((pal_mask > 0) << 7);
    write_byte_strict(file, b);
    // write palettes
    for (int i = 0; i < 8; i++)
    {
        uint8_t n = (pal_mask & 2) << 6;
        if (pal_mask & 1)
        {
            write_byte_strict(file, snif->pals[i][0] | n | (i >= 4 ? 0x40 : 0));
            write_byte_strict(file, snif->pals[i][1] | ((i % 4) << 6));
            write_byte_strict(file, snif->pals[i][2]);
        }
        pal_mask >>= 1;
    }

    ////////////////////////
    // write ppu chr banks
    ////////////////////////
    write_byte_strict(file, snif->ppu_mask);
    for (int i = 0; i < BITCOUNT[snif->ppu_mask]; i++)
        write_byte_strict(file, snif->ppu_banks[i]);

    ////////////////////////
    // write bkg data
    ////////////////////////
    if (snif->is_rleinc)
    {
        // write low bytes
        uint8_t tmp_bkg_data[SNIF_MAX_TILE];
        for (int i = 0; i < snif->bkg_data_len_lo; i++)
            tmp_bkg_data[i] = snif->bkg_data[i] & 0xFF;
        uint8_t tmp_out_data[SNIF_MAX_TILE * 2];
        int tmp_out_data_len;
        rleinc_encode(tmp_bkg_data, snif->bkg_data_len_lo, tmp_out_data, &tmp_out_data_len);
        for (int i = 0; i < tmp_out_data_len; i++)
            write_byte_strict(file, tmp_out_data[i]);
        // write high bytes
        for (int i = 0; i < snif->bkg_data_len_hi; i++)
            tmp_bkg_data[i] = snif->bkg_data[i] >> 8;
        rleinc_encode(tmp_bkg_data, snif->bkg_data_len_hi, tmp_out_data, &tmp_out_data_len);
        for (int i = 0; i < tmp_out_data_len; i++)
            write_byte_strict(file, tmp_out_data[i]);
    }
    else
    {
        // write low bytes
        for (int i = 0; i < snif->bkg_data_len_lo; i++)
            write_byte_strict(file, snif->bkg_data[i] & 0xFF);
        // write high bytes
        for (int i = 0; i < snif->bkg_data_len_hi; i++)
            write_byte_strict(file, snif->bkg_data[i] >> 8);
    }

    ////////////////////////
    // write spr data
    ////////////////////////
    // sort sprite for best compression
    // TODO
    // output each sprite
    short cur_pos = 0;
    char cur_pal = 0;
    char cur_flip = 0;
    for (int i = 0; i < snif->n_spr; i++)
    {
        // output flip
        char spr_flip = snif->spr_data[i].h | (snif->spr_data[i].v << 1);
        if (spr_flip != cur_flip)
        {
            cur_flip = spr_flip;
            write_byte_strict(file, SPRCMD_FLIP | spr_flip);
        }
        // output pallete
        if (cur_pal != snif->spr_data[i].pal)
        {
            cur_pal = snif->spr_data[i].pal;
            write_byte_strict(file, SPRCMD_PAL | snif->spr_data[i].pal);
        }
        // output position
        char x_tile = snif->spr_data[i].x / 8;
        char y_tile = snif->spr_data[i].y / 16;
        char spr_pos = y_tile * snif->w + x_tile;
        if (spr_pos != cur_pos)
        {
            write_byte_strict(file, SPRCMD_POS | (x_tile >> 4) | ((y_tile >> 4) << 1));
            write_byte_strict(file, ((x_tile & 0xF) << 4) | (y_tile & 0xF));
        }
        // output tile and offset
        char x_offset = snif->spr_data[i].x % 8;
        char y_offset = snif->spr_data[i].y % 16;
        write_byte_strict(file, 0x80 | (x_offset << 4) | y_offset);
        uint8_t t = snif->spr_data[i].t;
        t = (t << 1) + (t / 128);
        write_byte_strict(file, t);
        // go to next pos
        cur_pos = (cur_pos + 1) % (snif->w * snif->h);
    }
    write_byte_strict(file, SPRCMD_END);

    ////////////////////////
    // write chr data
    ////////////////////////
    for (int i = 0; i < snif->n_chr_tile; i++)
        for (int j = 0; j < TILE_BIN_SIZE; j++)
            write_byte_strict(file, snif->chr_data[i].binary[j]);

    fclose(file);
}