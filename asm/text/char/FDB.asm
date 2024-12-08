FDB:
    ; set number of char to read to 0
    LDA #$00
    STA txt_vars+0
    ; and reset dialog box
    JSR dialog_reset
    ; return
    RTS
