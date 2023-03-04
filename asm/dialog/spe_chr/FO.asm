; case FO
@FO:
    ; fade_color = next_char()
    ; JSR read_next_char
    ; STA fade_color
    ; set fade timer
    mov fade_timer, #FADE_TIME
    ; set fade out flag
    and_adr effect_flags, #($FF - EFFECT_FLAG_FADE)
    RTS
