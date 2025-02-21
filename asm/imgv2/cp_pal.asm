copy_palettes:
    ; Y = 3*8
    LDY #3*8
    ; if img_flag.evispr
    LDA img_flag
    AND #IMG_FLAG_EVISPR
    BEQ :+
        ; Y = 3*3-1
        LDY #3*3-1
        ; for Y to 0 (included)
        @cp_evi:
            ; img_pals[Y+12+1] = evi_pals_spr[Y]
            LDA evi_pals_spr, Y
            STA img_pals+12+1, Y
            ; continue
            DEY
            BPL @cp_evi
        ; Y = 3*4
        LDY #3*4
    :

    ; for Y to 0 (included)
    @cp_normal:
        ; img_pals[Y] = img_tmp_pals[Y]
        LDA img_tmp_pals, Y
        STA img_pals, Y
        ; continue
        DEY
        BPL @cp_normal

    ; return
    RTS
