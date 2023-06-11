; case PHT
@PHT:
    ; photo = next_char()
    JSR read_next_char
    BEQ @PHT_end
        ; set photo draw flag
        ORA #$80
        ; save photo index
        STA img_photo
        DEC img_photo
        ; return
    @PHT_end:
    RTS
