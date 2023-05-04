; TODO description

.segment "TXT_BNK"
.incbin "./text.bin"

.segment "CODE_BNK"
lz_bnk_table:
.byte $83
.byte $83
.byte $84
.byte $84
.byte $85
.byte $85
.byte $86

lz_adr_table_lo:
.byte $00
.byte $6B
.byte $29
.byte $AA
.byte $AA
.byte $2F
.byte $22

lz_adr_table_hi:
.byte $A0
.byte $B3
.byte $A5
.byte $B5
.byte $A5
.byte $B7
.byte $A9
