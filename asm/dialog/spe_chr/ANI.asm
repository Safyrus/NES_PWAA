; case ANI
@ANI:
    ; character_animation = next_char()
    JSR read_next_char
    STA img_animation
    BNE @ANI_spr_end
        JSR img_spr_clear
    @ANI_spr_end:
    ;
    JSR find_anim
    ; set text bank
    mov MMC5_RAM_BNK, #TEXT_BUF_BNK
    RTS
