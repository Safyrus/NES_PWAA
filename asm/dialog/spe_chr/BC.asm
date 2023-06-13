; case BC
BC:
    ; txt_bck_color = next_char()
    JSR read_next_char
    STA txt_bck_color
    RTS
