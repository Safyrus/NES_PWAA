; case ACT
ACT:

    ; last_act_ptr = act_ptr
    mov last_act_ptr+0, act_ptr+0
    mov last_act_ptr+1, act_ptr+1
    mov last_act_ptr+2, act_ptr+2

    ; last_act_ptr = act_ptr
    mov act_ptr+0, txt_rd_ptr+0
    mov act_ptr+1, txt_rd_ptr+1
    mov act_ptr+2, lz_idx

    ; max_choice = 0
    LDX #$00
    STX max_choice
    ; while(true)
    @ACT_while:
        ; choice_jmp_table[X] = read_next_jmp()
        JSR read_next_jmp
        LDA txt_jump_buf+0
        STA choice_jmp_table, X
        INX
        LDA txt_jump_buf+1
        STA choice_jmp_table, X
        INX
        LDA txt_jump_buf+2
        STA choice_jmp_table, X
        INX
        ; max_choice++
        INC max_choice
        ; if txt_jump_flag_buf.cond
        BIT txt_jump_flag_buf
        BVC :+
            ; A = read_next_char()
            JSR read_next_char
            ; if not evidence_flags[A]
            JSR get_dialog_flag
            BNE :+
                ; max_choice--
                DEC max_choice
                DEX
                DEX
                DEX
        :
    
        ; skip_until_b()
        :
            JSR read_next_char
            CMP #SPE_CHR::LB
            BNE :-

        ; if not txt_jump_flag_buf.next break
        BIT txt_jump_flag_buf
        BMI @ACT_while

    ora_adr max_choice, #$80

    @ACT_end:
    RTS
