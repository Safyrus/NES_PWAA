; case ANI
@ANI:
    ; character_animation = next_char()
    JSR read_next_char
    STA img_animation
    ;
    JSR find_anim
    ; set text bank
    LDA #TEXT_BUF_BNK
    STA MMC5_RAM_BNK
    RTS
