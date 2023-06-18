sprite_fliker:
    ; sprite flickering effect
    LDX #(RES_SPR*4)
    LDY #$FC
    @sprite_fliker_loop:
        ; byte 0
        LDA OAM, Y
        PHA
        LDA OAM, X
        STA OAM, Y
        PLA
        STA OAM, X
        INX
        INY
        ; byte 1
        LDA OAM, Y
        PHA
        LDA OAM, X
        STA OAM, Y
        PLA
        STA OAM, X
        INX
        INY
        ; byte 2
        LDA OAM, Y
        PHA
        LDA OAM, X
        STA OAM, Y
        PLA
        STA OAM, X
        INX
        INY
        ; byte 3
        LDA OAM, Y
        PHA
        LDA OAM, X
        STA OAM, Y
        PLA
        STA OAM, X
        INX
        TYA
        sub #3+4
        TAY
        ; next
        CPX #$80 - (RES_SPR*2)
        blt @sprite_fliker_loop

    LDY #$3F
    for_x @sprite_fliker_buf, #RES_SPR
        LDA spr_x_buf, X
        STA tmp
        LDA spr_x_buf, Y
        STA spr_x_buf, X
        LDA tmp
        STA spr_x_buf, Y
        ; next
        DEY
    to_x_inc @sprite_fliker_buf, #32
    @sprite_fliker_end:
