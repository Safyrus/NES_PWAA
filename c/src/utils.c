#include <stdlib.h>
#include <string.h>

#include "utils.h"
#include "file_utils.h"

uint64_t hash(const char *data, int size)
{
    uint64_t hash = FNV_OFFSET;
    for (int i = 0; i < size; i++)
    {
        hash ^= (uint64_t)(unsigned char)(data[i]);
        hash *= FNV_PRIME;
    }
    return hash;
}

uint64_t hash_str(const char *str)
{
    uint64_t hash = FNV_OFFSET;
    for (const char *p = str; *p; p++)
    {
        hash ^= (uint64_t)(unsigned char)(*p);
        hash *= FNV_PRIME;
    }
    return hash;
}

uint64_t hash_file(const char *filename)
{
    FILE *f = fopen(filename, "rb");
    if (!f)
        return -1;
    uint64_t hash = FNV_OFFSET;
    uint8_t b;
    while (fread(&b, 1, 1, f))
    {
        hash ^= (uint64_t)b;
        hash *= FNV_PRIME;
    }
    fclose(f);
    return hash;
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
