CLR:
    ; clear_dialog_flag(read_char())
    JSR read_char
    JSR clear_dialog_flag
    ; return
    RTS
