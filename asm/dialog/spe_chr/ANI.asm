; case ANI
@ANI:
    ; character_animation = next_char()
    JSR read_next_char
    STA img_animation
    ;
    BNE @ANI_spr_end
        JSR img_spr_clear
        ;
        LDA #IMG_BUF_BNK
        STA MMC5_RAM_BNK
        ; clear IMG_CHR_BUF_HI
        LDA #$00
        for_x @clr_chr, #0
            STA IMG_CHR_BUF_HI+$000, X
            STA IMG_CHR_BUF_HI+$100, X
            STA IMG_CHR_BUF_HI+$200, X
        to_x_inc @clr_chr, #0
        ;
        LDA #TEXT_BUF_BNK
        STA MMC5_RAM_BNK
    @ANI_spr_end:
    ;
    JSR find_anim
    ; set text bank
    mov MMC5_RAM_BNK, #TEXT_BUF_BNK
    RTS
