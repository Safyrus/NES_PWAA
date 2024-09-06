; TODO description

.segment "TXT_BNK"
.incbin "./text.bin"

.segment "CODE_BNK"
lz_bnk_table:
.byte TXT_BNK + $00
.byte TXT_BNK + $00
.byte TXT_BNK + $01
.byte TXT_BNK + $01

lz_adr_table_lo:
.byte $00
.byte $68
.byte $37
.byte $4E

lz_adr_table_hi:
.byte $A0
.byte $B0
.byte $A0
.byte $AF
