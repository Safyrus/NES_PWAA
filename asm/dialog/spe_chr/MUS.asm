; case MUS
@MUS:
    ; m = next_char()
    JSR read_next_char
    STA music
    ; play_music(m)
    ; TODO
    RTS
