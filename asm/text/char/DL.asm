DL:
    ; text_wait = read_char()
    JSR read_char
    STA text_wait
    ; set number of char to read to 0
    LDA #$00
    STA txt_vars+0
    ; return
    RTS
