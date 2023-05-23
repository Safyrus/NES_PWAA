NAMES_ADR_LO:
.byte $80+$00 ; [START] (not a name because name[0]=don't display name. use as offset)
.byte $80+$00 ; ???
.byte $80+$02 ; PHOENIX
.byte $80+$06 ; MIA
.byte $80+$08 ; BUTZ
.byte $80+$0B ; JUDGE
.byte $80+$0E ; PAYNE
.byte $80+$11 ; SAHWIT
.byte $80+$15 ; CLOCK
.byte $80+$18 ; CELLULAR
.byte $80+$1D ; MAYA
.byte $80+$20 ; GUMSHOE
.byte $80+$24 ; POLICE
.byte $80+$28 ; GROSSBERG
.byte $80+$2D ; EDGWORTH
.byte $80+$32 ; APRIL
.byte $80+$35 ; BELLBOY
.byte $80+$39 ; WHITE
.byte $80+$3C ; PHONE
.byte $80+$3F ; TV
.byte $80+$41 ; WILL
.byte $80+$44 ; OLDBAG
.byte $80+$48 ; PENNY
.byte $80+$4B ; CODY
.byte $80+$4E ; MANELLA
.byte $80+$52 ; VASQUEZ
.byte $80+$56 ; LOTTA
.byte $80+$59 ; PARROT
.byte $80+$5D ; UNCLE
.byte $80+$60 ; KARMA
.byte $80+$63 ; MISSILE
.byte $80+$66 ; GUARD
.byte $80+$6A ; YOGI
.byte $80+$6D ; TEACHER
.byte $80+$71 ; [END] (size of last name)


; update name_adr & name_size
update_name:
    push_ax
    LDX name_idx
    ; name_adr = (NAME_CHR_BANK << 8) + NAMES_ADR_LO[X]
    LDA NAMES_ADR_LO, X
    STA name_adr
    ; name_size = NAMES_ADR_LO[X+1] - NAMES_ADR_LO[X]
    INX
    LDA NAMES_ADR_LO, X
    sub name_adr+0
    STA name_size
    ; return
    pull_ax
    RTS
