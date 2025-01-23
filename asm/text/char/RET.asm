RET:
    ; restore saved text address
    ; and load text if needed
    LDA jmp_sav+0
    STA txt_ptr+0
    LDA jmp_sav+1
    STA txt_ptr+1
    LDA jmp_sav+2
    CMP lz_idx
    BEQ :+
        JSR lz_decode
    :
    STA lz_idx
    ; return
    RTS
