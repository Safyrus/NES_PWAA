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
.byte TXT_BNK + $06
.byte TXT_BNK + $06

lz_adr_table_lo:
.byte $00
.byte $8A
.byte $16
.byte $3B
.byte $6A
.byte $FB
.byte $32
.byte $CB
.byte $5C
.byte $59
.byte $41
.byte $37
.byte $F5

lz_adr_table_hi:
.byte $A0
.byte $B3
.byte $A5
.byte $B5
.byte $A5
.byte $B6
.byte $A9
.byte $BB
.byte $AD
.byte $BE
.byte $AF
.byte $A0
.byte $B1
