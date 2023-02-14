; case SP
@SP:
    ; for i from 0 to 4
    LDX #$00
    @sp_loop:
        ; p = next_char()
        JSR read_next_char
        ; palette[i] = palette_table[p]
        JSR set_img_spr_palette
        ; continue
        INX
        CPX #$04
        BNE @sp_loop
    RTS
