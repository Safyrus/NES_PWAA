scroll_nt:
    ; change nametable to use
    eor_adr img_flag, #IMG_FLAG_OTHERNT
    ; change palettes to use
    eor_adr scroll_pal_flip, #$80
    ; if palettes are 'flip'
    BMI :+
        ; X = 1
        LDX #$01
        JMP :++
    ; else
    :
        ; X = 7
        LDX #$07
    :

    ; set bank
    push mmc5_banks+2
    mov mmc5_banks+2, #GENERAL_BNK
    STA MMC5_PRG_BNK1

    ; img_idx = ???
    ; Y = (img_idx*32)+7
    LDA scroll_pal_flip
    LSR
    LSR
    ORA #$07
    TAY
    ; img_pals[X:X+6], img_tmp_pals[X:X+6] = SCROLL_IMG_PALS_BUF[Y:Y+6]
    LDA SCROLL_IMG_PALS_BUF+$4000+0, Y
    STA img_pals+0, X
    STA img_tmp_pals+0, X
    LDA SCROLL_IMG_PALS_BUF+$4000+1, Y
    STA img_pals+1, X
    STA img_tmp_pals+1, X
    LDA SCROLL_IMG_PALS_BUF+$4000+2, Y
    STA img_pals+2, X
    STA img_tmp_pals+2, X
    LDA SCROLL_IMG_PALS_BUF+$4000+3, Y
    STA img_pals+3, X
    STA img_tmp_pals+3, X
    LDA SCROLL_IMG_PALS_BUF+$4000+4, Y
    STA img_pals+4, X
    STA img_tmp_pals+4, X
    LDA SCROLL_IMG_PALS_BUF+$4000+5, Y
    STA img_pals+5, X
    STA img_tmp_pals+5, X

    ; restore bank
    pull mmc5_banks+2
    STA MMC5_PRG_BNK1

    ; return
    RTS
