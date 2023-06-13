; case DL
DL:
    ; delay = next_char()
    JSR read_next_char
    STA txt_delay
    RTS
