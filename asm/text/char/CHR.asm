CHR:
    ; read argument first byte
    JSR read_char
    ; read argument second byte
    JSR read_char
    ; return
    RTS
