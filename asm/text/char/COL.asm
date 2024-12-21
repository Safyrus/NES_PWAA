COL:
    ; c = read_char()
    JSR read_char
    ; if c & $40
    ASL
    BPL :+
        LSR
        ; TODO
        BRK
    ; else
    :
        ; color = c << 6
        ASL
        ASL
        ASL
        ASL
        ASL
        STA text_color
    ; return
    RTS
