; char (c) = A
; clobber A, Y
print:
    ; ----------------
    ; Put char into Dialog box bufer
    ; ----------------
    ; switch bank
    ; TODO: check if bug can arise
    ; if NMI restore banks before the end of the function.
    ; Normally, we print at the start of the frame,
    ; so this should not occure, but still.
    LDY #IMG_BUF_BNK
    STY MMC5_RAM_BNK
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
