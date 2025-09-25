read_jump:
    ; jmp_buf_cond = true
    LDA #$FF
    STA jmp_buf_cond

    ; read address
    JSR read_char
    STA jmp_buf+0
    JSR read_char
    STA jmp_buf+1
    JSR read_char
    STA jmp_buf+2

    ; if jump contain condition
    ASL
    BPL :+
        ; read condition
        JSR read_char
        ; jmp_buf_cond = get_dialog_flag(condition)
        JSR get_dialog_flag
        STA jmp_buf_cond
    :

    ; return
    RTS


text_jump:
    ; txt_ptr = jmp_buf.ptr
    LDA jmp_buf+1
    ASL
    STA txt_ptr+0
    LDA jmp_buf+0
    AND #$3F
    LSR
    ORA #$60
    STA txt_ptr+1
    LDA txt_ptr+0
    ROR
    STA txt_ptr+0
    ; if lz_idx != jmp_buf.bnk
    LDA jmp_buf+2
    AND #$3F
    CMP lz_idx
    BEQ :+
        ; lz_idx = jmp_buf.bnk
        STA lz_idx
        ; lz_decode()
        JSR lz_decode
    :
    ; return
text_jump_ret:
    RTS


JMP_:
    ; read jump
    JSR read_jump
    ; if condition is false
    LDA jmp_buf_cond
        ; return
        BEQ text_jump_ret
    ; jump
    ; return
    JMP text_jump
