; case FI
@FI:
    ; fade_color = next_char()
    ; JSR read_next_char
    ; STA fade_color
    ; set fade timer
    mov fade_timer, #FADE_TIME
    ; set fade in flag
    ora_adr effect_flags, #EFFECT_FLAG_FADE
    RTS
