#include <stdlib.h>
#include <string.h>

#include <errno.h>
#include <dirent.h>
#include <sys/stat.h>

#include "file_utils.h"

void print_stat_error(const char *filename)
{
    switch (errno)
    {
    case EACCES:
        fprintf(stderr, "Error: can't get stat for '%s' (access denied)\n", filename);
        break;
    case EIO:
        fprintf(stderr, "Error: can't get stat for '%s' (filesystem error)\n", filename);
        break;
    case ENAMETOOLONG:
        fprintf(stderr, "Error: can't get stat for '%s' (name too long)\n", filename);
        break;
    case ENOENT:
        fprintf(stderr, "Error: can't get stat for '%s' (invalid name)\n", filename);
        break;
    case ENOTDIR:
        fprintf(stderr, "Error: can't get stat for '%s' (not a directory)\n", filename);
        break;
    default:
        fprintf(stderr, "Error: can't get stat for '%s'\n", filename);
        break;
    }
}

void list_files(const char *dirname, FILE *outputfile, const char recursive)
{
    //
    int dirname_len = 0;
    while (dirname[dirname_len])
        dirname_len++;

    // open directory
    DIR *dir;
    if (!(dir = opendir(dirname)))
    {
        fprintf(stderr, "Error: can't open dir '%s'\n", dirname);
        return;
    }

    // list entry in the directory
    struct dirent *entry;
    struct stat s;
    char name[1024];
    while ((entry = readdir(dir)) != NULL)
    {
        // get file path
        if (dirname[dirname_len - 1] == SEP)
            sprintf(name, "%s%s", dirname, entry->d_name);
        else
            sprintf(name, "%s%c%s", dirname, SEP, entry->d_name);
        // get entry info
        if (stat(name, &s))
        {
            print_stat_error(name);
            continue;
        }
        // act based on entry type
        if (s.st_mode & S_IFREG) // file
        {
            // output file name
            fprintf(outputfile, "%s\n", name);
        }
        else if (s.st_mode & S_IFDIR) // directory
        {
            // skip if no recursion
            if (!recursive)
                continue;
            // skip if it is the current or previous directory
            if (!strcmp(entry->d_name, ".") || !strcmp(entry->d_name, ".."))
                continue;
            // search recursively
            list_files(name, outputfile, recursive);
        }
        else
        {
            fprintf(stderr, "Error: unknow entry type for '%s' %d\n", entry->d_name, s.st_mode);
        }
    }

    // close the directory
    closedir(dir);
}

uint8_t read_byte_strict(FILE *file)
{
    uint8_t b;
    if (fread(&b, 1, 1, file) != 1)
    {
        fprintf(stderr, "Error (read_byte_strict): while reading byte from file\n");
        exit(1);
    }
    return b;
}

void write_byte_strict(FILE *file, const uint8_t byte)
{
    if (fwrite(&byte, 1, 1, file) != 1)
    {
        fprintf(stderr, "Error (write_byte_strict): while writing byte from file\n");
        exit(1);
    }
}

int mkdir_rec(char *path, int offset)
{
    char *cur_path = path + offset;
    int path_len = strlen(cur_path);
    char sep[2];
    sep[0] = SEP;
    sep[1] = '\0';
    int dir_offset = strcspn(cur_path, sep);
    if (dir_offset != path_len)
    {
        // create first directory
        path[offset + dir_offset] = 0;
        mkdir(path);
        path[offset + dir_offset] = SEP;
        // create rest of directories
        return mkdir_rec(path, offset + dir_offset + 1);
    }
    else
    {
        // suppose last part is a file
        return 0;
    }
}

int join_path(char *root, const char *suffix)
{
    int root_len = strlen(root);
    int suffix_len = strlen(suffix);
    if (root[root_len - 1] != SEP)
        root[root_len++] = SEP;
    strcpy(&root[root_len], suffix);
    return root_len + suffix_len;
}

FILE *fopen_strict(const char *filename, const char *mode)
{
    FILE *f = fopen(filename, mode);
    if (!f)
    {
        fprintf(stderr, "Error: can't open file '%s'\n", filename);
        exit(1);
    }
    return f;
}

int read_line(FILE *file, char *buf, int buf_len)
{
    int i = 0;
    int c;
    do
    {
        c = fgetc(file);
        buf[i] = c;
        i++;
    } while (c != EOF && c != '\n' && i < buf_len);
    i--;
    buf[i] = 0;
    return i;
}

void remove_ext(char *str)
{
    // start at the end of the string
    int i = strlen(str);
    while (i >= 0)
    {
        // if no extension
        if (str[i] == SEP)
            return;
        // at extention
        if (str[i] == '.')
        {
            // cut there
            str[i] = 0;
            return;
        }
        // continue
        i--;
    }
}

void remove_dir_path(char *str)
{
    // start at the end of the string
    int l = strlen(str);
    int i = l;
    while (i >= 0)
    {
        // if at extension
        if (str[i] == SEP)
        {
            // cut there
            i++;
            for (int j = 0; i <= l;)
                str[j++] = str[i++];
            return;
        }
        // continue
        i--;
    }
}

int rmdir_rec(const char *dirname, int silence)
{
    //
    int dirname_len = 0;
    while (dirname[dirname_len])
        dirname_len++;

    // open directory
    DIR *dir;
    if (!(dir = opendir(dirname)))
    {
        if (!silence)
            fprintf(stderr, "Error: can't open dir '%s'\n", dirname);
        return 1;
    }

    // list entry in the directory
    struct dirent *entry;
    struct stat s;
    char name[1024];
    while ((entry = readdir(dir)) != NULL)
    {
        // get file path
        if (dirname[dirname_len - 1] == SEP)
            sprintf(name, "%s%s", dirname, entry->d_name);
        else
            sprintf(name, "%s%c%s", dirname, SEP, entry->d_name);
        // get entry info
        if (stat(name, &s))
        {
            print_stat_error(name);
            continue;
        }
        // act based on entry type
        if (s.st_mode & S_IFREG) // file
        {
            // delete file
            remove(name);
        }
        else if (s.st_mode & S_IFDIR) // directory
        {
            // skip if it is the current or previous directory
            if (!strcmp(entry->d_name, ".") || !strcmp(entry->d_name, ".."))
                continue;
            // search recursively
            rmdir_rec(name, silence);
        }
        else
        {
            if (!silence)
                fprintf(stderr, "Error: unknow entry type for '%s' %d\n", entry->d_name, s.st_mode);
        }
    }

    // close the directory
    closedir(dir);

    // remove now empty directory
    remove(dirname);
    return 0;
}
