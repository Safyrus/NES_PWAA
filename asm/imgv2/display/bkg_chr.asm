; X, Y = chr idx
display_chr:
    ; arguments
    mov tmp+3, #>IMG_CHR_LO_ADR
    mov tmp+7, #>IMG_CHR_HI_ADR
    mov tmp+9, #>IMG_CHR_SPR
    mov tmp+4, #<(spr_bnks-1)
    mov tmp+5, #>(spr_bnks-1)
    mov tmp+10, #<img_tmp_pals
    mov tmp+11, #>img_tmp_pals
    mov tmp+12, #IMG_BUF_BNK
    ; set image drawing flag
    ora_adr effect_flags, #EFFECT_FLAG_IMAGE
    ; display_img(...)
    ; return
    JMP display_img


; X = bkg idx
display_bkg:
    STX cur_bkg
    ; arguments
    mov tmp+3, #>IMG_BKG_LO_ADR
    mov tmp+7, #>IMG_BKG_HI_ADR
    mov tmp+9, #>IMG_CHR_SPR
    mov tmp+4, #<(spr_bnks-1)
    mov tmp+5, #>(spr_bnks-1)
    mov tmp+10, #<img_tmp_pals
    mov tmp+11, #>img_tmp_pals
    mov tmp+12, #IMG_BUF_BNK
    LDY #$00
    ; set image drawing flag
    ora_adr effect_flags, #EFFECT_FLAG_IMAGE
    ; display_img(...)
    ; return
    JMP display_img
