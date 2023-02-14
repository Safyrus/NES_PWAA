; case NAM
@NAM:
    ; name = next_char()
    JSR read_next_char
    STA txt_name
    RTS
