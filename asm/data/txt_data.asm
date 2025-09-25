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

lz_adr_table_lo:
.byte $00
.byte $E4
.byte $EC
.byte $81
.byte $65
.byte $EC

lz_adr_table_hi:
.byte $80
.byte $92
.byte $84
.byte $95
.byte $86
.byte $97
