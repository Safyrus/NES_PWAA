EVT_HPS:
    ; c = read_char()
    JSR read_char
    ; t = (c & %0011000) >> 3
    PHA
    AND #%0011000
    LSR
    LSR
    LSR
    TAX
    ; n = c & %0000111
    PLA
    AND #%0000111
    ; set_hp(n, t)
    ; return
    JMP set_hp
