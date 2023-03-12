; TODO description

.segment "TXT_BNK"
.incbin "text.bin"

.segment "CODE_BNK"
lz_bnk_table:
.byte $88

lz_adr_table_lo:
.byte $00

lz_adr_table_hi:
.byte $A0
