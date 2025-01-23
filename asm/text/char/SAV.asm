SAV:
    ; save current text address
    LDA txt_ptr+0
    STA jmp_sav+0
    LDA txt_ptr+1
    STA jmp_sav+1
    LDA lz_idx
    STA jmp_sav+2
    ; return
    RTS
