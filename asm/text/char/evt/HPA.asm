EVT_HPA:
    ; c = read_char()
    JSR read_char
    TAX
    ; n = c & %0000111
    AND #%0000111
    TAY
    ; s = c & %1000000
    TXA
    AND #%1000000
    ; n *= s ? -1 : 1
    BEQ :+
        TYA
        EOR #$FF
        TAY
        INY
    :
    ; t = (c & %0011000) >> 3
    TXA
    AND #%0011000
    LSR
    LSR
    LSR
    TAX
    ; set_hp(hps[t]+n, t)
    ; return
    TYA
    add hps, X
    JMP set_hp
