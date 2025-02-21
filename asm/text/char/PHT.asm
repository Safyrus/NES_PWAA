PHT:
    ; p = read_char()
    JSR read_char
    ; if p == new_photo (same as last)
    CMP new_photo
    BNE :+
        ; p = none
        LDA #$FF
    :
    ; new_photo = p
    STA new_photo

    ; return
    RTS
