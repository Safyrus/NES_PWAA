SAV:
    ; save adr
    mov txt_save_adr+0, txt_rd_ptr+0
    mov txt_save_adr+1, txt_rd_ptr+1
    mov txt_save_adr+2, lz_idx
    RTS
