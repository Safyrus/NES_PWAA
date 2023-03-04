; case SP
@SP:
    ; for i from 0 to 4
    for_x @sp_loop, #0
        ; p = next_char()
        JSR read_next_char
        ; palette[i] = palette_table[p]
        JSR set_img_spr_palette
    to_x_inc @sp_loop, #4
    RTS
