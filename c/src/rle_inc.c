#include <stdio.h>
#include <stdlib.h>

#include "rle_inc.h"
#include "file_utils.h"

void rleinc_decode(const uint8_t *data, uint8_t *out, uint16_t *out_len)
{
    int idx = 0;
    *out_len = 0;
    uint8_t loop = 1;
    uint8_t n, b, b1, b2;
    while (loop)
    {
        b = data[idx++]; // next byte
        if (b >= RLEINC_CMD_RUN)
        {
            n = 0x101 - b;
            b = data[idx++];
            for (; n > 0; n--)
                out[(*out_len)++] = b;
        }
        else if (b >= RLEINC_CMD_DBL)
        {
            n = b - 0x7D;
            b1 = data[idx++];
            b2 = data[idx++];
            for (; n > 0; n--)
            {
                out[(*out_len)++] = b1;
                // swap b1 & b2
                b = b1;
                b1 = b2;
                b2 = b;
            }
        }
        else if (b >= RLEINC_CMD_SEQ)
        {
            n = b - 0x3F;
            b = data[idx++];
            for (; n > 0; n--)
                out[(*out_len)++] = b++;
        }
        else if (b >= RLEINC_CMD_END)
        {
            loop = 0;
        }
        else // LIT
        {
            for (b += 1; b > 0; b--)
                out[(*out_len)++] = data[idx++];
        }
    }
}

// TODO: find a way to not repeat code between
//       this function and the similar one without file
void rleinc_fdecode(FILE *data, uint8_t *out, uint16_t *out_len)
{
    *out_len = 0;
    uint8_t loop = 1;
    uint8_t n, b, b1, b2;
    while (loop)
    {
        b = read_byte_strict(data); // next byte
        if (b >= RLEINC_CMD_RUN)
        {
            n = 0x101 - b;
            b = read_byte_strict(data);
            for (; n > 0; n--)
                out[(*out_len)++] = b;
        }
        else if (b >= RLEINC_CMD_DBL)
        {
            n = b - 0x7D;
            b1 = read_byte_strict(data);
            b2 = read_byte_strict(data);
            for (; n > 0; n--)
            {
                out[(*out_len)++] = b1;
                // swap b1 & b2
                b = b1;
                b1 = b2;
                b2 = b;
            }
        }
        else if (b >= RLEINC_CMD_SEQ)
        {
            n = b - 0x3F;
            b = read_byte_strict(data);
            for (; n > 0; n--)
                out[(*out_len)++] = b++;
        }
        else if (b >= RLEINC_CMD_END)
        {
            loop = 0;
        }
        else // LIT
        {
            for (b += 1; b > 0; b--)
                out[(*out_len)++] = read_byte_strict(data);
        }
    }
}

void flush_lit(const uint8_t *data, int idx, uint8_t *out, int *out_len, uint8_t *n_lit)
{
    if (*n_lit == 0)
        return;
    printf("LIT\n");
    out[(*out_len)++] = RLEINC_CMD_LIT + (*n_lit) - 1;
    for (; (*n_lit) > 0; (*n_lit)--)
        out[(*out_len)++] = data[idx - (*n_lit)];
}

void rleinc_encode(const uint8_t *data, const int len, uint8_t *out, int *out_len)
{
    // init vars
    uint8_t n_lit = 0;
    int idx = 0;
    *out_len = 0;
    // for every byte of data
    while (idx < len)
    {
        // get next 2 bytes
        uint8_t b = data[idx];
        uint8_t b1 = data[idx];
        uint8_t b2 = data[idx + 1] ? idx + 1 < len : 0;

        // try to compress with RUN
        uint8_t n = 1;
        for (; n < 97; n++)
        {
            // stop if end of data or not the same byte as the first
            if (idx + n >= len || data[idx + n] != b)
                break;
        }
        // if successfull
        if (n > 1)
        {
            // flush LIT if needed
            flush_lit(data, idx, out, out_len, &n_lit);
            // use RUN
            printf("RUN\n");
            out[(*out_len)++] = RLEINC_CMD_RUN + (0x101 - n);
            out[(*out_len)++] = b;
            idx += n;
            // and continue compression
            continue;
        }

        // try with DBL
        n = 2;
        for (; n < 34; n++)
        {
            // stop if end of data or not a correct byte for DBL
            if (idx + n >= len || data[idx + n] != b1)
                break;
            // swap b1 & b2
            uint8_t tmp = b1;
            b1 = b2;
            b2 = tmp;
        }
        // if successfull
        if (n > 2)
        {
            // flush LIT if needed
            flush_lit(data, idx, out, out_len, &n_lit);
            // use DBL
            printf("DBL\n");
            out[(*out_len)++] = RLEINC_CMD_DBL + (n - 0x7D);
            out[(*out_len)++] = b1;
            out[(*out_len)++] = b2;
            idx += n;
            // and continue compression
            continue;
        }

        // try with SEQ
        n = 1;
        b1 = b;
        for (; n < 64; n++)
        {
            // stop if end of data or not a correct byte for SEQ
            if (idx + n >= len || data[idx + n] != b1 + 1)
                break;
            b1++;
        }
        // if successfull
        if (n > 1)
        {
            // flush LIT if needed
            flush_lit(data, idx, out, out_len, &n_lit);
            // use SEQ
            printf("SEQ\n");
            out[(*out_len)++] = RLEINC_CMD_SEQ + (n - 0x3F);
            out[(*out_len)++] = b;
            idx += n;
            // and continue compression
            continue;
        }

        // flush LIT buffer if full
        if (n_lit >= 64)
            flush_lit(data, idx, out, out_len, &n_lit);
        // if all fail, use LIT by
        // puting the current byte in the LIT buffer
        n_lit++;
        // and continue compression
        idx++;
    }
    // and END to end of compress data
    out[(*out_len)++] = RLEINC_CMD_END;
}
