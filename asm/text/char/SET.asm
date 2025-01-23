SET:
    ; set_dialog_flag(read_char())
    JSR read_char
    JSR set_dialog_flag
    ; return
    RTS
