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
.byte $93
.byte $36
.byte $70
.byte $96
.byte $0E
.byte $6B
.byte $17
.byte $08
.byte $7E
.byte $FD
.byte $93
.byte $00

lz_adr_table_hi:
.byte $A0
.byte $B3
.byte $A5
.byte $B5
.byte $A5
.byte $B7
.byte $A9
.byte $BC
.byte $AD
.byte $BD
.byte $AD
.byte $BE
.byte $B0
