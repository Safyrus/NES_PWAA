#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "compact.h"
#include "file_utils.h"
#include "utils.h"

int asm_snif_img_one(const char *filename, FILE *img_data, FILE *img_names, uint8_t *hash_list, int *index, int *size, int *ptr_adr, char img_type, int *anim_idx, int *anim_time, int *offset, int *photo_index)
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
    long fpos = ftell(file);
    if (fpos < 0)
    {
        fprintf(stderr, "Error (asm_snif_img_one): cannot determine file size\n");
        exit(1);
    }
    size_t img_size = (unsigned long)fpos - HASH_SIZE;
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
    if (t == IMG_TYPE_BKG)
        fprintf(img_names, "BKG_%s = %d\n", constname, (*index));
    else if (t == IMG_TYPE_CHR)
        fprintf(img_names, "CHR_%s = %d\n", constname, (*index));
    else if (t == IMG_TYPE_PHT)
    {
        fprintf(img_names, "PHT_%s = %d\n", constname, (*photo_index));
        (*photo_index)++;
    }

    // add pointer to img_ptr
    if ((*index) % 256 == 0)
        ptr_adr[(*index) / 256] = (*size);
    (*size) += (signed)img_size + 2;
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
    int photo_index = 0;
    while (1)
    {
        // get next filename and stop if list of files is empty
        char filename[MAX_FILENAME_LEN];
        if (!read_line(filelist, filename, MAX_FILENAME_LEN))
            break;
        // add it to image asm/bin files
        int _dontcare;
        asm_snif_img_one(filename, img_data, img_names, hash_list, index, size, ptr_adr, img_type, &_dontcare, &_dontcare, &_dontcare, &photo_index);
    }
}

void asm_snif(const char *final_chr, const char *data_path, const char *tmp_snif_dir)
{
    // malloc
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
        int anim_idx, anim_time, anim_offset, _dontcare;
        int img_idx = asm_snif_img_one(filename, img_data, img_names, hash_list, &index, &size, ptr_adr, IMG_TYPE_CHR, &anim_idx, &anim_time, &anim_offset, &_dontcare);
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
        uint64_t h = hash_str(f) % MAX_ANIM;
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
        write_byte_strict(anim_data, n * 3 + 1);
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
