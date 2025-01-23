JMP_:
    ; read address
    JSR read_char
    STA jmp_buf+0
    JSR read_char
    STA jmp_buf+1
    JSR read_char
    STA jmp_buf+2

    ; if condition
    ASL
    BPL :+
        ; read condition
        JSR read_char
        ; if flag clear
        JSR get_dialog_flag
            ; return
            BEQ @ret
    :

    ; --------
    ; jump
    ; --------
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
        ; lz_decode()
        JSR lz_decode
    :
    ; lz_idx = jmp_buf.bnk
    STA lz_idx

    @ret:
    ; return
    RTS