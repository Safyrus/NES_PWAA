; case FNT
@FNT:
    ; font = next_char()
    JSR read_next_char
    STA txt_font
    RTS
