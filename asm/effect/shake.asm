
shake:
    ; shake
    LDA shake_timer
    bze @shake_end
        ; update timer
        DEC shake_timer
        ; shake on the x axis
        LSR
        AND #$03
        STA scroll_x
        ; update sprites
        LDY #$03
        for_x @shake_spr, #0
            LDA spr_x_buf, X
            sub scroll_x
            STA OAM, Y
            ; next
            INY
            INY
            INY
            INY
        to_x_inc @shake_spr, #64
    @shake_end:
