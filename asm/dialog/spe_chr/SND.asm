; case SND
@SND:
    ; s = next_char()
    JSR read_next_char
    STA sound
    ; play_sound(s)
    ; TODO
    RTS
