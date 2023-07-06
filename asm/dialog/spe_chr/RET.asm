RET:
    ; load adr
    mov txt_rd_ptr+0, txt_save_adr+0
    mov txt_rd_ptr+1, txt_save_adr+1
    ;
    LDX txt_save_adr+2
    JMP lz_check
