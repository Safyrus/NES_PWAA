; use tmp 0:3
find_anim:
    push_ay

    LDA tmp+0
    PHA
    LDA tmp+1
    PHA
    LDA tmp+2
    PHA
    LDA tmp+3
    PHA

    ;
    mov tmp+3, img_anim+0
    mov tmp+2, img_anim+1
    ;
    sta_ptr tmp, img_anim_table
    ;
    LDY #$00
    STY anim_img_counter
    STY anim_frame_counter

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
    mov_ptr anim_base_adr, tmp+0

    PLA
    STA tmp+3
    PLA
    STA tmp+2
    PLA
    STA tmp+1
    PLA
    STA tmp+0

    pull_ay
    RTS
