; char (c) = A
; clobber A, X, Y
print:
    ; ----------------
    ; Put char into Dialog box bufer
    ; ----------------
    ; switch bank
    TAY
    LDA mmc5_banks+0
    PHA
    TYA
    LDY text_box_bnk
    STY mmc5_banks+0
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
    PLA
    STA mmc5_banks+0
    STA MMC5_RAM_BNK

    ; print_offset++
    INC print_offset

    ; if a bip is not playing
    LDX #FAMISTUDIO_SFX_CH1
    LDA famistudio_sfx_ptr_hi, X
    BNE :+
    ; and if a bip is selected
    LDA bip
    BMI :+
        ; sfx_chn = FAMISTUDIO_SFX_CH1
        STX sfx_chn
        ; play_sfx(bip, sfx_chn)
        JSR play_sfx-1
        ; sfx_chn = FAMISTUDIO_SFX_CH0
        mov sfx_chn, #FAMISTUDIO_SFX_CH0
    :

    ; return
    RTS
