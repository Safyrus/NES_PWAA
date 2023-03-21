; use tmp 0:3
find_anim:
    push_ay

    push tmp+0
    push tmp+1
    push tmp+2
    push tmp+3

    ;
    mov tmp+3, img_anim+0
    mov tmp+2, img_anim+1
    ;
    sta_ptr tmp, img_anim_table
    ;
    LDY #$00
    STY anim_img_counter
    STY anim_frame_counter
    ora_adr effect_flags, #EFFECT_FLAG_BKG

    @loop:
        LDA #$00
        CMP tmp+3
        BNE @next
        CMP tmp+2
        BEQ @find

        @next:
        LDA (tmp), Y
        add_A2ptr tmp

        dec_16 tmp+2
        JMP @loop
    @find:
    ;
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
