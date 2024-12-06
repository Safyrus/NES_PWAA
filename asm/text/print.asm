; char (c) = A
; clobber A, Y
print:
    ; switch bank
    LDY #IMG_BUF_BNK
    STY MMC5_RAM_BNK ; TODO: check if bug can occure if NMI restore bank between
    ; Y = print_offset
    LDY print_offset
    ; dialogbox[Y] = c (low)
    STA DB_ADR_LO, Y
    LDA text_font
    AND #$01
    CLC
    ROR
    ROR
    ORA DB_ADR_LO, Y
    STA DB_ADR_LO, Y
    ; dialogbox[Y] = c (high)
    LDA text_font
    LSR
    ORA text_color
    STA DB_ADR_HI, Y
    ; restore bank
    LDY mmc5_banks+0
    STY MMC5_RAM_BNK
    ; print_offset++
    INC print_offset
    ; return
    RTS
