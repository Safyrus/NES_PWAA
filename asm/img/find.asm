; use tmp 0:3
find_anim:
    push_ay

    push tmp+0
    push tmp+1
    push tmp+2
    push tmp+3

    ;
    LDA #ANI_BNK
    STA mmc5_banks+3
    STA MMC5_PRG_BNK2
    ;
    LDA img_character
    CLC
    ROR
    STA tmp+3
    ROR
    AND #$80
    STA tmp+2
    LDA img_animation
    ORA tmp+2
    STA tmp+2
    ;
    sta_ptr tmp, img_anim_table
    ;
    LDY #$00
    STY anim_img_counter
    STY anim_frame_counter
    ora_adr effect_flags, #EFFECT_FLAG_BKG

    TYA ; A = 0
    @loop:
        CMP tmp+3
        BNE @next
        CMP tmp+2
        BEQ @find

        @next:

        LDA (tmp), Y
        add_A2ptr tmp

        ; if out of bank
        LDA tmp+1
        CMP #$E0
        blt @loop_back
            sub #$20
            STA tmp+1
            INC mmc5_banks+3
            mov MMC5_PRG_BNK2, mmc5_banks+3

        @loop_back:
        dec_16 tmp+2
        JMP @loop
    @find:
    ;
    mov anim_bnk, mmc5_banks+3
    LDA tmp+0
    STA anim_base_adr+0
    STA anim_adr+0
    LDA tmp+1
    STA anim_base_adr+1
    STA anim_adr+1

    pull tmp+3
    pull tmp+2
    pull tmp+1
    pull tmp+0

    pull_ay
    RTS
