EVT_CRI:
    ; cr_correct_idx = read_char()
    JSR read_char
    STA cr_correct_idx
    ; return
    RTS
