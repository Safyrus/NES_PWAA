; case FI
@FI:
    ; fade_color = next_char()
    ; JSR read_next_char
    ; STA fade_color
    ; set fade timer
    LDA #FADE_TIME
    STA fade_timer
    ; set fade in flag
    LDA effect_flags
    ORA #EFFECT_FLAG_FADE
    STA effect_flags
    RTS
