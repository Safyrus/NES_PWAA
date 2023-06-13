; case FNT
FNT:
    ; font = next_char()
    JSR read_next_char
    STA txt_font
    ; print_ext_val = col + (font >> 1)
    LDA print_ext_val
    AND #$C0
    STA print_ext_val
    LDA txt_font
    LSR
    add print_ext_val
    STA print_ext_val
    ; return
    RTS
