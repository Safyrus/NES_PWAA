#ifndef RLE_INC_H
#define RLE_INC_H

#include <stdint.h>
#include <stdbool.h>

#define RLEINC_CMD_LIT 0x00
#define RLEINC_CMD_END 0x40
#define RLEINC_CMD_SEQ 0x41
#define RLEINC_CMD_DBL 0x80
#define RLEINC_CMD_RUN 0xA0

// int rleinc_idx;

// uint8_t rleinc_next(uint8_t *data, int len)
// {
//     if (len >= rleinc_idx)
//     {
//         printf("[ERROR] (rleinc): cannot fetch data, out of bounds.\n");
//         exit(1);
//     }
//     printf("debug rleinc_idx %d", rleinc_idx);
//     return data[rleinc_idx++];
// }

uint8_t rleinc_runsize(uint8_t *data, int len, int i);

uint8_t rleinc_seqsize(uint8_t *data, int len, int i);

uint8_t rleinc_dblsize(uint8_t *data, int len, int i);

void rleinc_encode(uint8_t *data, int len, uint8_t *out, int *out_len, bool do_print);

#endif