dialog_reset:
    ; print_offset = $22 (1 line + 2 char)
    mov print_offset, #$22
    ; print_start = print_offset
    STA print_start
    ; text_lb_offset = $40 (2 lines + 2 char)
    mov text_lb_offset, #$42
    ; clear dialog box
    JSR clear_dialog
    ; return
    RTS
