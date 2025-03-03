EVT_CRN:
    ; flag = read_char()
    JSR read_char
    PHA
    ; jmp = read_jmp()
    JSR read_jump
    PLA
    TAX
    ; switch to GENERAL bank
    push mmc5_banks+0
    mov mmc5_banks+0, #GENERAL_BNK
    STA MMC5_RAM_BNK
    ; evi_ptr[flag] = jmp
    LDA jmp_buf+0
    STA evi_jmp_b0, X
    LDA jmp_buf+1
    STA evi_jmp_b1, X
    LDA jmp_buf+2
    STA evi_jmp_b2, X
    ; restore bank
    pull mmc5_banks+0
    STA MMC5_RAM_BNK
    ; return
    RTS
