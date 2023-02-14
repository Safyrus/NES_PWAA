; case BP
@BP:
    ; for i from 0 to 4
    LDX #$00
    @bp_loop:
        ; p = next_char()
        JSR read_next_char
        ; palette[i] = palette_table[p]
        JSR set_img_bck_palette
        ; continue
        INX
        CPX #$04
        BNE @bp_loop
    RTS
