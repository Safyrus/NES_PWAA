; X = negative index
remove_bkg:
    STX cur_bkg
    ; disable sprites
    ora_adr img_flag, #IMG_FLAG_UNSPRITE
    ; clear background tiles
    LDA #$00
    TAX
    @clear_tiles:
        STA IMG_BKG_LO_ADR+$000, X
        STA IMG_BKG_LO_ADR+$100, X
        STA IMG_BKG_LO_ADR+$200, X
        STA IMG_BKG_HI_ADR+$000, X
        STA IMG_BKG_HI_ADR+$100, X
        STA IMG_BKG_HI_ADR+$200, X
        ; continue
        INX
        BNE @clear_tiles
    ; clear background color
    STA img_tmp_pals+0

    ; update and return
    JMP call_update_img
