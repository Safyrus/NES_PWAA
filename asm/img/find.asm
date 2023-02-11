; use tmp 0:3
find_anim:
    PHA
    TYA
    PHA

    ;
    LDA img_anim+0
    STA tmp+3
    LDA img_anim+1
    STA tmp+2
    ;
    LDA #<img_anim_table
    STA tmp+0
    LDA #>img_anim_table
    STA tmp+1
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
    LDA tmp+0
    STA anim_base_adr+0
    LDA tmp+1
    STA anim_base_adr+1

    PLA
    TAY
    PLA
    RTS
