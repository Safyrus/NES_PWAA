#ifndef RLE_INC_H
#define RLE_INC_H

#include <stdint.h>
#include <stdbool.h>

#define RLEINC_CMD_LIT 0x00
#define RLEINC_CMD_END 0x40
#define RLEINC_CMD_SEQ 0x41
#define RLEINC_CMD_DBL 0x80
#define RLEINC_CMD_RUN 0xA0

void rleinc_decode(const uint8_t *data, uint8_t *out, uint16_t *out_len);
void rleinc_fdecode(FILE *data, uint8_t *out, uint16_t *out_len);

void rleinc_encode(const uint8_t *data, const int len, uint8_t *out, int *out_len);
void rleinc_encodef(const uint8_t *data, const int len, FILE *out);

#endif