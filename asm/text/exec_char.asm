; X = char
exec_char:
    ; - - - - - - - -
    ; switch (c)
    ; - - - - - - - -
    ; push return adr
    LDA #>(@ret-1)
    PHA
    LDA #<(@ret-1)
    PHA
    ; push jump adr
    LDA @switch_hi, X
    PHA
    LDA @switch_lo, X
    PHA
    ; jump
    @ret:
    RTS

    @switch_lo:
        .byte <(END-1)
        .byte <(LB-1)
        .byte <(DB-1)
        .byte <(FDB-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
        .byte <(@ret-1)
    
    @switch_hi:
        .byte >(END-1)
        .byte >(LB-1)
        .byte >(DB-1)
        .byte >(FDB-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)
        .byte >(@ret-1)

