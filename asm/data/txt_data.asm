; TODO description

.segment "TXT_BNK"
.incbin "./text.bin"

.segment "CODE_BNK"
lz_bnk_table:
.byte TXT_BNK + $00
.byte TXT_BNK + $00
.byte TXT_BNK + $01
.byte TXT_BNK + $01
.byte TXT_BNK + $02
.byte TXT_BNK + $02
.byte TXT_BNK + $03

lz_adr_table_lo:
.byte $00
.byte $7D
.byte $34
.byte $83
.byte $85
.byte $0D
.byte $2E

lz_adr_table_hi:
.byte $A0
.byte $B3
.byte $A5
.byte $B5
.byte $A5
.byte $B7
.byte $A9
