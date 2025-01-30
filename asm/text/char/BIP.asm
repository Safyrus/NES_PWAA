BIP:
    ; b = read_char()
    JSR read_char
    ; if b == bip
    CMP bip
    BNE :+
        ; b = none
        LDA #$FF
    :
    ; bip = b
    STA bip
    ; return
    RTS
