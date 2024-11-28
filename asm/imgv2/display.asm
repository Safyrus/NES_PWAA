; X, Y = chr idx
display_chr:
    ; bkg_lo
    ; bkg_hi
    mov tmp+3, #>(IMG_CHR_LO_ADR+$60)
    mov tmp+7, #>(IMG_CHR_HI_ADR+$60)
    JMP display_img


; X = bkg idx
display_bkg:
    ; bkg_lo
    ; bkg_hi
    mov tmp+3, #>(IMG_BKG_LO_ADR+$60)
    mov tmp+7, #>(IMG_BKG_HI_ADR+$60)
    ; Y = 0
    LDY #$00
    JMP display_img
