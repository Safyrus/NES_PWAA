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
.byte TXT_BNK + $03
.byte TXT_BNK + $04
.byte TXT_BNK + $04
.byte TXT_BNK + $05
.byte TXT_BNK + $05
.byte TXT_BNK + $06

lz_adr_table_lo:
.byte $00
.byte $94
.byte $42
.byte $93
.byte $B8
.byte $37
.byte $98
.byte $77
.byte $2D
.byte $5E
.byte $D6
.byte $7D
.byte $D8

lz_adr_table_hi:
.byte $A0
.byte $B3
.byte $A5
.byte $B5
.byte $A5
.byte $B7
.byte $A9
.byte $BB
.byte $AC
.byte $BD
.byte $AD
.byte $BE
.byte $AF
