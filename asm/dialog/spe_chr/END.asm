; case END
@END_char:
    ; should not occure, so jump forever
    JSR print_flush
    JMP @END_char
    RTS
