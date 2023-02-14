; case FO
@FO:
    ; fade_color = next_char()
    ; JSR read_next_char
    ; STA fade_color
    ; set fade timer
    LDA #FADE_TIME
    STA fade_timer
    ; set fade out flag
    LDA effect_flags
    AND #($FF - EFFECT_FLAG_FADE)
    STA effect_flags
    RTS
