; case PHT
@PHT:
    ; photo = next_char()
    JSR read_next_char
    ; set photo draw flag
    ORA #$80
    ; save photo index
    STA img_photo
    ; return
    RTS
