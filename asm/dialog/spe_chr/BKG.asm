; case BKG
@BKG:
    ; background = next_char()
    JSR read_next_char
    STA img_background
    ;
    JSR find_anim
    ; set text bank
    LDA #TEXT_BUF_BNK
    STA MMC5_RAM_BNK
    RTS
