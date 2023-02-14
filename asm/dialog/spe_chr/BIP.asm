; case BIP
@BIP:
    ; txt_bip = next_char()
    JSR read_next_char
    STA bip
    RTS
