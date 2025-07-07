#ifndef UTILS_H
#define UTILS_H

#include <stdint.h>

// #define HASH_SIZE 64
#define HASH_SIZE 4
#define FNV_OFFSET 14695981039346656037UL
#define FNV_PRIME 1099511628211UL

// #define FULL_CONST_NAME

/*
TODO
*/
uint64_t hash(const char *data, int size);

/*
TODO
*/
uint64_t hash_str(const char *str);

/*
TODO
*/
uint64_t hash_file(const char *filename);

/*
TODO
*/
int compare_hash(uint8_t *hash_list, int size, uint8_t *hash);

/*
TODO
*/
void filename2const(char *filename);

/*
TODO
*/
int strendwith(const char *str, const char *end);

#endif