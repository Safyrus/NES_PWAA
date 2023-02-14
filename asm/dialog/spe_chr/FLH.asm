; case FLH
@FLH:
    ; flash_color = next_char()
    ; JSR read_next_char
    ; STA flash_color
    ; set flash timer
    LDA #$FF
    STA scroll_timer
    RTS
