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
.byte $55
.byte $F5
.byte $59
.byte $2F
.byte $8C
.byte $6B

lz_adr_table_hi:
.byte $A0
.byte $B3
.byte $A4
.byte $B5
.byte $A5
.byte $B6
.byte $A8
