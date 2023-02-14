; case DL
@DL:
    ; delay = next_char()*2
    JSR read_next_char
    ASL
    STA txt_delay
    RTS
