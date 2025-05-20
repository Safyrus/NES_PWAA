#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <direct.h>

#include "compact.h"
#include "snif.h"
#include "file_utils.h"

#define HASH_SIZE 64

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

void merge_snif_tiles(const char *in_snif_folder, const char *in_chr_file, int n_res_tile, const char *out_snif_folder, const char *out_chr_file, int verbose)
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
                printf("SNIF Merge: skip non SNIF file '%s'\n", filename);
            continue;
        }
        if (verbose)
        {
            int n_use_tiles = 0;
            for (int i = 0; i < MAX_TILES; i++)
                n_use_tiles += tile_list[i].type != TILE_TYPE_FREE ? 1 : 0;
            int percent_use = ((float)n_use_tiles / MAX_TILES) * 100;
            printf("\e[2K\rSNIF Merge: merge '%s' (CHR usage: %d%%)", filename, percent_use);
        }
        // read SNIF file
        new_tile_list_size = read_sniffile_tiles(filename, new_tile_list, snif);
        // add tiles to region
        for (int i = 0; i < new_tile_list_size; i++)
        {
            int idx = add_bkg_tile(tile_cmp_matrix, tile_list, &new_tile_list[i]);
            snif->bkg_data[i] = (snif->bkg_data[i] & 0xC000) | idx;
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
        // find image hash
        char hash[HASH_SIZE + 1];
        const char wanted_str[] = "hashori\":\"";
        for (int i = 0; i < snif->metadata_len; i++)
        {
            int j = 0;
            int find = 1;
            while (wanted_str[j])
            {
                if (wanted_str[j] != snif->metadata[i + j])
                {
                    find = 0;
                    break;
                }
                j++;
            }
            if (find)
            {
                strncpy(hash, &snif->metadata[i + j], HASH_SIZE);
                hash[64] = 0;
                break;
            }
        }
        // change metadata to only be the hash value
        snif->metadata_len = HASH_SIZE;
        strcpy(snif->metadata, hash);
        // write temporary 'snif' file
        snif->n_chr_tile = 0;
        snif->is_rleinc = 1;
        mkdir_rec(outname, 0);
        write_snif(outname, snif);
    }
    if (verbose)
        printf("\n");

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
    fclose(filelist);

    if (verbose)
        printf("SNIF Merge: done\n");
    return;
}

void merge_chrs(const char *final_chr)
{
    // open final CHR file
    FILE *foutchr = fopen_strict(final_chr, "wb");

    // for each region
    char chrpath[11] = "out/r0.chr";
    for (int r = 0; r < 4; r++)
    {
        // open region file
        chrpath[5] = '0' + r;
        FILE *f = fopen_strict(chrpath, "rb");

        // copy data
        char tilebuf[16];
        for (int i = 0; i < MAX_TILES; i++)
        {
            if (fread(tilebuf, 16, 1, f) != 1)
            {
                for (int j = 0; j < 16; j++)
                    tilebuf[j] = 0;
            }
            fwrite(tilebuf, 16, 1, foutchr);
        }

        fclose(f);
    }

    fclose(foutchr);
}

void filename2const(char *filename)
{
    remove_ext(filename);
    int i = 0;
    while (filename[i])
    {
        if ((filename[i] >= 'A' && filename[i] <= 'Z') ||
            (filename[i] >= '0' && filename[i] <= '9'))
        {
            // do nothing
        }
        else if (filename[i] >= 'a' && filename[i] <= 'z')
            filename[i] -= 0x20;
        else
            filename[i] = '_';
        i++;
    }
}

int compare_hash(uint8_t *hash_list, int size, uint8_t *hash)
{
    // for each hash
    for (int i = 0; i < size; i++)
    {
        // compare it to the new hash
        int same = 1;
        for (int j = 0; j < HASH_SIZE; j++)
            if (hash_list[i * HASH_SIZE + j] != hash[j])
            {
                same = 0;
                break;
            }
        // if there are the same
        if (same)
            // return its index
            return i;
    }
    // not found
    return -1;
}

int asm_snif_img_one(const char *filename, FILE *img_data, FILE *img_names, uint8_t *hash_list, int *index, int *size, int *ptr_adr, char img_type, int *anim_idx, int *anim_time, int *offset)
{
    // skip if file is not a snif file
    if (!strendwith(filename, ".snif"))
        return -1;
    // open file, seek to end, tell pos to get size
    FILE *file = fopen_strict(filename, "rb");
    uint8_t w;
    fseek(file, HASH_SIZE, SEEK_SET);
    fread(&w, 1, 1, file);
    w = (w & 0x1F) + 1;
    fseek(file, 0, SEEK_END);
    long img_size = ftell(file) - HASH_SIZE;
    rewind(file);
    // find image type
    int t = IMG_TYPE_BKG;
    if (w < 0x20)
        t = IMG_TYPE_PHT;
    (*offset) = is_filename_anim(filename, anim_idx, anim_time);
    if ((*offset))
        t = IMG_TYPE_CHR;
    // skip if not the correct image type
    if (t != img_type)
    {
        fclose(file);
        return -1;
    }
    // if image was already added
    // and is in the same region
    // TODO: check region
    uint8_t hash[HASH_SIZE];
    fread(hash, HASH_SIZE, 1, file);
    int h_idx = compare_hash(hash_list, (*index), hash);
    if (h_idx >= 0)
    {
        // we don't need to do anything
        // and we return the image index
        // printf("same hash found at %d for %s\n", h_idx, filename);
        fclose(file);
        return h_idx;
    }
    // add the hash to the hash list
    for (int i = 0; i < HASH_SIZE; i++)
        hash_list[(*index) * HASH_SIZE + i] = hash[i];
    // write size with 2 bytes
    if (img_size > 0xFFFF)
    {
        fprintf(stderr, "Error: somethings wrong here\n");
        exit(1);
    }
    char c = (img_size + 2) & 0xFF;
    fwrite(&c, 1, 1, img_data);
    c = ((img_size + 2) >> 8) & 0xFF;
    fwrite(&c, 1, 1, img_data);
    // copy file (because snif file should have no meta (except hash) and CHR)
    uint8_t buf[img_size];
    fread(buf, img_size, 1, file);
    fwrite(buf, img_size, 1, img_data);
    fclose(file);
    // add name to img_names with index
    char constname[MAX_FILENAME_LEN];
    strcpy(constname, filename);
    filename2const(constname);
    fprintf(img_names, "%s = %d\n", constname, (*index));
    // add pointer to img_ptr
    if ((*index) % 256 == 0)
        ptr_adr[(*index) / 256] = (*size);
    (*size) += img_size;
    (*index)++;
    // return the added image index
    return (*index) - 1;
}

void asm_snif_img(const char *tmp_snif_dir, FILE *img_data, FILE *img_names, uint8_t *hash_list, int *index, int *size, int *ptr_adr, char img_type)
{
    // for each file
    FILE *filelist = fopen_strict("tmp", "wb+");
    list_files(tmp_snif_dir, filelist, 1);
    rewind(filelist);
    while (1)
    {
        // get next filename and stop if list of files is empty
        char filename[MAX_FILENAME_LEN];
        if (!read_line(filelist, filename, MAX_FILENAME_LEN))
            break;
        // add it to image asm/bin files
        int _dontcare;
        asm_snif_img_one(filename, img_data, img_names, hash_list, index, size, ptr_adr, img_type, &_dontcare, &_dontcare, &_dontcare);
    }
}

#define FNV_OFFSET 14695981039346656037UL
#define FNV_PRIME 1099511628211UL
uint64_t hash(const char *str)
{
    uint64_t hash = FNV_OFFSET;
    for (const char *p = str; *p; p++)
    {
        hash ^= (uint64_t)(unsigned char)(*p);
        hash *= FNV_PRIME;
    }
    return hash;
}

void asm_snif(const char *final_chr, const char *data_path, const char *tmp_snif_dir)
{
    // malloc
    const int MAX_ANIM = 128 * 128;
    const int MAX_IMG = 128 * 128;
    const int ANIM_BUF_SIZE = 1024;
    uint8_t *anim_table = malloc(MAX_ANIM * ANIM_BUF_SIZE);
    uint8_t *hash_list = malloc(MAX_IMG * HASH_SIZE);
    if (!anim_table || !hash_list)
    {
        fprintf(stderr, "Error (asm_snif): can't malloc\n");
        exit(1);
    }
    for (int i = 0; i < MAX_ANIM; i++)
    {
        anim_table[i * ANIM_BUF_SIZE + 0] = 0;   // string
        anim_table[i * ANIM_BUF_SIZE + 256] = 0; // 1st byte = nb frame, rest is data bytes
    }

    // merge 4 CHR region into one CHR file
    merge_chrs(final_chr);
    printf("char merged\n");

    // open asm files
    int l = strlen(data_path);
    char path[l + 32];
    strcpy(path, data_path);
    join_path(path, "anim_data.bin");
    FILE *anim_data = fopen_strict(path, "wb");
    path[l] = 0;
    join_path(path, "anim_names.asm");
    FILE *anim_names = fopen_strict(path, "w");
    path[l] = 0;
    join_path(path, "anim_ptr.asm");
    FILE *anim_ptr = fopen_strict(path, "w");
    path[l] = 0;
    join_path(path, "img_data.bin");
    FILE *img_data = fopen_strict(path, "wb");
    path[l] = 0;
    join_path(path, "img_names.asm");
    FILE *img_names = fopen_strict(path, "w");
    path[l] = 0;
    join_path(path, "img_ptr.asm");
    FILE *img_ptr = fopen_strict(path, "w");

    // add background images to image files
    int index = 0;
    int size = 0;
    int ptr_adr[512];
    printf("add bkg\n");
    asm_snif_img(tmp_snif_dir, img_data, img_names, hash_list, &index, &size, ptr_adr, IMG_TYPE_BKG);

    ////////////////
    // add character images
    ////////////////
    printf("add chr\n");
    // for each file
    FILE *filelist = fopen_strict("tmp", "wb+");
    list_files(tmp_snif_dir, filelist, 1);
    rewind(filelist);
    while (1)
    {
        // get next filename and stop if list of files is empty
        char filename[MAX_FILENAME_LEN];
        if (!read_line(filelist, filename, MAX_FILENAME_LEN))
            break;
        // add it to image asm/bin files
        int anim_idx, anim_time, anim_offset;
        int img_idx = asm_snif_img_one(filename, img_data, img_names, hash_list, &index, &size, ptr_adr, IMG_TYPE_CHR, &anim_idx, &anim_time, &anim_offset);
        // stop if was not a chr type
        if (img_idx < 0)
            continue;
        // get the anim name without frame info
        // and cut it to the last 256 chars
        filename[anim_offset] = 0;
        char *f = filename;
        if (anim_offset > 255)
            f = filename + anim_offset - 255;
        filename2const(f);
        // find the anim idx based on the name
        int h = hash(f) % MAX_ANIM;
        while (1)
        {
            char *name = (char *)(&anim_table[h * ANIM_BUF_SIZE]);
            if (name[0] == 0)
            {
                strcpy(name, f);
                break;
            }
            if (strcmp(name, f) == 0)
                break;
            h = (h + 1) % MAX_ANIM;
        }
        // append this frame at that idx
        uint8_t n = anim_table[h * ANIM_BUF_SIZE + 256];
        anim_table[h * ANIM_BUF_SIZE + 256 + 1 + (n * 4) + 0] = anim_idx;
        anim_table[h * ANIM_BUF_SIZE + 256 + 1 + (n * 4) + 1] = (img_idx >> 0) & 0xFF;
        anim_table[h * ANIM_BUF_SIZE + 256 + 1 + (n * 4) + 2] = (img_idx >> 8) & 0xFF;
        anim_table[h * ANIM_BUF_SIZE + 256 + 1 + (n * 4) + 3] = anim_time;
        anim_table[h * ANIM_BUF_SIZE + 256]++;
    }

    // write anim files
    int a_idx = 0;
    int a_size = 0;
    int a_ptr_adr[256];
    for (int i = 0; i < MAX_ANIM; i++)
    {
        // skip empty anim
        char *name = (char *)(&anim_table[i * ANIM_BUF_SIZE]);
        if (name[0] == 0)
            continue;
        // add name to anim_names with index
        fprintf(anim_names, "%s = %d\n", name, a_idx);
        // sort frames in anims
        uint8_t n = anim_table[i * ANIM_BUF_SIZE + 256];
        for (int i0 = 0; i0 < n - 1; i0++)
        {
            int min_val = anim_table[i * ANIM_BUF_SIZE + 256 + 1 + (i0 * 4)];
            int min_idx = i0;
            for (int i1 = i0; i1 < n; i1++)
            {
                int val = anim_table[i * ANIM_BUF_SIZE + 256 + 1 + (i1 * 4)];
                if (val < min_val)
                {
                    min_val = val;
                    min_idx = i1;
                }
            }
            uint8_t tmp[4];
            for (int j = 0; j < 4; j++)
            {
                tmp[j] = anim_table[i * ANIM_BUF_SIZE + 256 + 1 + (min_idx * 4) + j];
                anim_table[i * ANIM_BUF_SIZE + 256 + 1 + (min_idx * 4) + j] = anim_table[i * ANIM_BUF_SIZE + 256 + 1 + (i0 * 4) + j];
                anim_table[i * ANIM_BUF_SIZE + 256 + 1 + (i0 * 4) + j] = tmp[j];
            }
        }
        // add anim in anim_data
        write_byte_strict(anim_data, n*3+1);
        // printf("anim (%d) '%s' size=%d\n", i, name, n);
        for (int j = 0; j < n; j++)
        {
            uint8_t il = anim_table[i * ANIM_BUF_SIZE + 256 + 1 + (j * 4) + 1];
            uint8_t ih = anim_table[i * ANIM_BUF_SIZE + 256 + 1 + (j * 4) + 2];
            uint8_t t = anim_table[i * ANIM_BUF_SIZE + 256 + 1 + (j * 4) + 3];
            write_byte_strict(anim_data, il);
            write_byte_strict(anim_data, ih);
            write_byte_strict(anim_data, t);
        }
        // add pointer to anim_ptr
        if (a_idx % 256 == 0)
            a_ptr_adr[a_idx / 256] = a_size;
        //
        a_size += n * 3 + 1;
        a_idx++;
    }

    // write img pointer list
    fprintf(img_ptr, "img_ptr_list_lo:\n");
    for (int i = 0; i <= index / 256; i++)
        fprintf(img_ptr, ".byte (%d >> 0) & $FF\n", ptr_adr[i]);
    fprintf(img_ptr, "\nimg_ptr_list_hi:\n");
    for (int i = 0; i <= index / 256; i++)
        fprintf(img_ptr, ".byte ((%d >> 8) & $1F) + $80\n", ptr_adr[i]);
    fprintf(img_ptr, "\nimg_ptr_list_bnk:\n");
    for (int i = 0; i <= index / 256; i++)
        fprintf(img_ptr, ".byte ((%d >> 13) & $7F) + IMG_BNK\n", ptr_adr[i]);
    // write evidence pointer 'list'
    fprintf(img_ptr, "\nevi_ptr_list_lo:\n");
    fprintf(img_ptr, ".byte (%d >> 0) & $FF\n", size);
    fprintf(img_ptr, "\nevi_ptr_list_hi:\n");
    fprintf(img_ptr, ".byte ((%d >> 8) & $1F) + $80\n", size);
    fprintf(img_ptr, "\nevi_ptr_list_bnk:\n");
    fprintf(img_ptr, ".byte ((%d >> 13) & $7F) + IMG_BNK\n", size);
    // write anim pointer list
    fprintf(anim_ptr, "anim_ptr_list_lo:\n");
    for (int i = 0; i <= a_idx / 256; i++)
        fprintf(anim_ptr, ".byte (%d >> 0) & $FF\n", a_ptr_adr[i]);
    fprintf(anim_ptr, "\nanim_ptr_list_hi:\n");
    for (int i = 0; i <= a_idx / 256; i++)
        fprintf(anim_ptr, ".byte ((%d >> 8) & $1F) + $80\n", a_ptr_adr[i]);
    fprintf(anim_ptr, "\nanim_ptr_list_bnk:\n");
    for (int i = 0; i <= a_idx / 256; i++)
        fprintf(anim_ptr, ".byte ((%d >> 13) & $7F) + ANI_BNK\n", a_ptr_adr[i]);

    // add photo images to image files
    printf("add pht\n");
    asm_snif_img(tmp_snif_dir, img_data, img_names, hash_list, &index, &size, ptr_adr, IMG_TYPE_PHT);

    free(anim_table);
    free(hash_list);
    // close files
    fclose(anim_data);
    fclose(anim_names);
    fclose(anim_ptr);
    fclose(img_data);
    fclose(img_names);
    fclose(img_ptr);
    printf("asm done\n");
}

int main(int argc, char const *argv[])
{
    if (argc <= 5)
    {
        printf("args: <input snif folder> <input chr file> <n reserved tiles> <outchr file> <asm data folder>\n");
        return 1;
    }

    int n_res = atoi(argv[3]);
    int len = strlen(argv[1]);
    char path[len + 4];
    char null_path[] = "";

    // todo: delete out folder
    // todo: create out folder
    strcpy(path, argv[1]);
    join_path(path, "r0");
    printf("Merge file from r0\n");
    merge_snif_tiles(path, argv[2], n_res, "out/r0", "out/r0.chr", 1);
    path[len] = 0;
    join_path(path, "r1");
    printf("Merge file from r1\n");
    merge_snif_tiles(path, null_path, 0, "out/r1", "out/r1.chr", 1);
    path[len] = 0;
    join_path(path, "r2");
    printf("Merge file from r2\n");
    merge_snif_tiles(path, null_path, 0, "out/r2", "out/r2.chr", 1);
    path[len] = 0;
    join_path(path, "r3");
    printf("Merge file from r3\n");
    merge_snif_tiles(path, null_path, 0, "out/r3", "out/r3.chr", 1);
    printf("Output to ASM\n");
    asm_snif(argv[4], argv[5], "out");
    printf("finished\n");

    return 0;
}
