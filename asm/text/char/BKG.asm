BKG:
    ; X = read argument
    JSR read_char
    ; if same as last
    CMP new_bkg
    BNE :+
        ; remove background
        ; by choosing a special background
        LDA #$80
    :
    ; tell main to change bkg
    STA new_bkg
    ; return
    RTS
