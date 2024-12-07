LB:
    ; flush text
    JSR flush
    ; print_offset &= $E
    ; (returning to start of line)
    LDA print_offset
    AND #$E0
    ; print_offset += text_lb_offset
    ; (e.g. if text_lb_offset = $20, text will go to next line)
    add text_lb_offset
    STA print_offset
    ; print_start = print_offset
    STA print_start
    ; return
    RTS
