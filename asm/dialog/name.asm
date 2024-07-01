NAMES_ADR_LO:
.byte $80 ; [START] (not a name because name[0]=don't display name. use as offset)
.byte $80 ; ???
.byte $82 ; Safyrus
.byte $86 ; A
.byte $87 ; B
.byte $88 ; [END] (size of last name)


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
