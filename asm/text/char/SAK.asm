SAK:
    ; read argument
    JSR read_char
    ;
    TAX
    AND #TXTARG_FORCE
    shift LSR, 4
    STA shake_force
    TXA
    AND #TXTARG_TIME
    shift ASL, 3
    STA shake_timer
    ; return
    RTS
