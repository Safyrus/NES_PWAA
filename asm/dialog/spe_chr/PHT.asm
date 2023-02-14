; case PHT
@PHT:
    ; photo = next_char()
    JSR read_next_char
    STA img_photo
    RTS
