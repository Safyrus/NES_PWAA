; case BP
@BP:
    ; for i from 0 to 4
    for_x @bp_loop, #0
        ; p = next_char()
        JSR read_next_char
        ; palette[i] = palette_table[p]
        JSR set_img_bck_palette
    to_x_inc @bp_loop, #4
    RTS
