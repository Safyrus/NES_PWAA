#include <stdio.h>
#include <stdlib.h>

#include "rle_inc.h"

uint8_t rleinc_runsize(uint8_t *data, int len, int i)
{
    uint8_t d = data[i];
    uint8_t run_size = 0;
    while (i < len && d == data[i] && run_size < 0x5F)
    {
        run_size++;
        i++;
    }
    return run_size;
}

uint8_t rleinc_seqsize(uint8_t *data, int len, int i)
{
    uint8_t d = data[i];
    uint8_t seq_size = 0;
    while (i < len && d == data[i] && seq_size < 0x3E)
    {
        seq_size++;
        i++;
        d++;
    }
    return seq_size;
}

uint8_t rleinc_dblsize(uint8_t *data, int len, int i)
{
    if (len >= i + 1)
    {
        printf("[WARNING] (rleinc): DBL out of bound.\n");
        return 0;
    }
    uint8_t d1 = data[i];
    uint8_t d2 = data[i + 1];
    uint8_t dbl_size = 0;
    while (i + 1 < len && d1 == data[i] && d2 == data[i + 1] && dbl_size < 0x1F * 2)
    {
        dbl_size += 2;
        i += 2;
    }
    return dbl_size;
}

void rleinc_encode(uint8_t *data, int len, uint8_t *out, int *out_len, bool do_print = false)
{
    int i = 0;
    *out_len = 0;
    while (i < len)
    {
        uint8_t run_size = rleinc_runsize(data, len, i);
        uint8_t seq_size = rleinc_seqsize(data, len, i);
        uint8_t dbl_size = rleinc_dblsize(data, len, i);
        uint8_t run_size = rleinc_runsize(data, len, i);
        uint8_t d1 = data[i];
        uint8_t d2 = 0;
        if (i + 1 < len)
            d2 = data[i + 1];

        uint8_t lit_data[0x40];
        uint8_t lit_data_len = 0;
        while ((run_size < 2 && seq_size < 2 && dbl_size < 3) && lit_data_len < 0x40)
        {
            lit_data[lit_data_len] = data[i];
            i++;
            if (i >= len)
                break;

            run_size = rleinc_runsize(data, len, i);
            seq_size = rleinc_seqsize(data, len, i);
            dbl_size = rleinc_dblsize(data, len, i);
            run_size = rleinc_runsize(data, len, i);
            d1 = data[i];
            d2 = 0;
            if (i + 1 < len)
                d2 = data[i + 1];
        }
        if (i >= len)
        {
            if (lit_data_len > 0)
            {
                if (do_print)
                    printf("[ENCODE]: LIT %d %d\n", lit_data_len - 1, i);
                out[*out_len] = lit_data_len - 1;
                *out_len++;
                for (int j = 0; j < lit_data_len; j++)
                {
                    out[*out_len] = lit_data[j];
                    *out_len++;
                }
            }
            break;
        }

        if (lit_data_len > 0)
        {
            if (do_print)
                printf("[ENCODE]: LIT %d %d\n", lit_data_len - 1, i);
            out[*out_len] = lit_data_len - 1;
            *out_len++;
            for (int j = 0; j < lit_data_len; j++)
            {
                out[*out_len] = lit_data[j];
                *out_len++;
            }
        }
        if (lit_data_len == 0x40)
            continue;

        if (run_size >= seq_size && run_size >= dbl_size)
        {
            if (do_print)
                printf("[ENCODE]: RUN", 0x101 - run_size, d1, i);
            out[*out_len] = 0x101 - run_size;
            *out_len++;
            out[*out_len] = d1;
            *out_len++;
            i += run_size;
        }
        else if (seq_size >= run_size && seq_size >= dbl_size)
        {
            if (do_print)
                printf("[ENCODE]: SEQ", seq_size + 0x3F, d1, i);
            out[*out_len] = seq_size + 0x3F;
            *out_len++;
            out[*out_len] = d1;
            *out_len++;
            i += seq_size;
        }
        else if (dbl_size >= run_size && dbl_size >= seq_size)
        {
            if (do_print)
                printf("[ENCODE]: DBL", dbl_size + 0x7D, d1, d2, i);
            out[*out_len] = dbl_size + 0x7D;
            *out_len++;
            out[*out_len] = d1;
            *out_len++;
            out[*out_len] = d2;
            *out_len++;
            i += dbl_size;
        }
        else
            printf("ERROR");
    }

    if (do_print)
        printf("[ENCODE]: END", i);
    out[*out_len] = RLEINC_CMD_END;
    *out_len++;
}
