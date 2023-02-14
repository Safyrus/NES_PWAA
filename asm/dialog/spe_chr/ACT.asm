; case ACT
@ACT:
    @ACT_while:
        ; read next jump adr
        JSR read_next_jmp

        ; if condition flag is present
        BIT txt_jump_buf+2
        BVC @ACT_cond_end
            ; c_idx = next_char()
            JSR read_next_char
            ; flag = dialog_flag[c_idx]
            JSR get_dialog_flag
            ; if flag clear then skip this choice
            BEQ @ACT_while_next
        @ACT_cond_end:

        ; get choice_jmp_table index
        LDA max_choice
        STA MMC5_MUL_A
        LDA #$03
        STA MMC5_MUL_B
        LDX MMC5_MUL_A
        ; copy jump adr to choice_jmp_table
        LDA txt_jump_buf+0
        STA choice_jmp_table, X
        INX
        LDA txt_jump_buf+1
        STA choice_jmp_table, X
        INX
        LDA txt_jump_buf+2
        STA choice_jmp_table, X
        ; increase the number of choice
        INC max_choice

        ; read choice text
        @ACT_while_read:
            JSR read_next_char
            ; todo print
            CMP #$01
            BNE @ACT_while_read

        ; while end
        @ACT_while_next:
        BIT txt_jump_flag_buf
        BMI @ACT_while

    ; display choice
    ; TODO
    RTS
