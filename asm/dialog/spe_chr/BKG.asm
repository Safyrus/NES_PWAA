; case BKG
@BKG:
    ; background = next_char()
    JSR read_next_char
    STA img_background
    LDA img_animation
    BNE @BKG_spr_end
        JSR img_spr_clear
        JSR img_spr_clear_buf
        LDA #TXT_BNK
        STA MMC5_RAM_BNK
    @BKG_spr_end:
    ;
    JSR find_anim
    ; set text bank
    mov MMC5_RAM_BNK, #TEXT_BUF_BNK
    RTS
