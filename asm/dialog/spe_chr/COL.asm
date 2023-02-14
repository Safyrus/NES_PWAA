; case COL
@COL:
    ; print_ext_val & 0x3F
    LDA print_ext_val
    AND #$3F
    STA print_ext_val
    ; col = next_char()
    JSR read_next_char
    ; (col-1) << 6
    SEC
    SBC #$01
    AND #$03
    CLC
    ROR
    ROR
    ROR
    ; print_ext_val | col
    ORA print_ext_val
    STA print_ext_val
    RTS
