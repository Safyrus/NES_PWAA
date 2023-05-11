; case COL
@COL:
    ; col = next_char()
    JSR read_next_char
    ; (col-1) << 6
    sub #$01
    AND #$03
    CLC
    shift ROR, 3
    ; print_ext_val = col + (font >> 1)
    STA print_ext_val
    LDA txt_font
    LSR
    add print_ext_val
    STA print_ext_val
    ; return
    RTS
