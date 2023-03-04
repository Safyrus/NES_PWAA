; case COL
@COL:
    ; print_ext_val & 0x3F
    and_adr print_ext_val, #$3F
    ; col = next_char()
    JSR read_next_char
    ; (col-1) << 6
    sub #$01
    AND #$03
    CLC
    shift ROR, 3
    ; print_ext_val | col
    ORA print_ext_val
    STA print_ext_val
    RTS
