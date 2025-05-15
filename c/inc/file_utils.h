#ifndef FILE_UTILS_H
#define FILE_UTILS_H

#include <stdio.h>
#include <stdint.h>


#ifdef _WIN32
#define SEP '\\'
#else
#define SEP '/'
#endif

void print_stat_error(const char *filename);
void list_files(const char *dirname, FILE *outputfile, const char recursive);
uint8_t read_byte_strict(FILE *file);
void write_byte_strict(FILE *file, const uint8_t byte);
int mkdir_rec(char *path, int offset);
int join_path(char *root, const char *suffix);
FILE *fopen_strict(const char *filename, const char *mode);
int read_line(FILE *file, char *buf, int buf_len);
void remove_ext(char *str);

#endif