; case JMP
JMP_char:
    JSR read_next_jmp
    ; if condition flag:
    BIT txt_jump_flag_buf
    BVC @JMP_char_cond_end
        ; c_idx = next_char()
        JSR read_next_char
        ; flag = dialog_flags[c_idx]
        JSR get_dialog_flag
        ; if flag clear then break
        BEQ @JMP_char_end
    @JMP_char_cond_end:
    JMP read_jump
    @JMP_char_end:
    RTS
