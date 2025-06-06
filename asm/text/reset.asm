dialog_reset:
    ; print_offset = DEFAULT_PRINT_OFFSET
    mov print_offset, #DEFAULT_PRINT_OFFSET
    ; print_start = print_offset
    STA print_start
    ; text_lb_offset = TWO_LINE_OFFSET_2_SPACE
    mov text_lb_offset, #TWO_LINE_OFFSET_2_SPACE
    ; clear dialog box
    JSR clear_dialog
    ; return
    RTS
