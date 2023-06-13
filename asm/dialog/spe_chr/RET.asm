RET:
    ; load adr
    mov txt_rd_ptr+0, txt_save_adr+0
    mov txt_rd_ptr+1, txt_save_adr+1
    ;
    LDX txt_save_adr+2
    CPX lz_idx
    STX lz_idx
    BNE @lz
    ; if text bank not the same
    LDA lz_bnk_table, X
    CMP lz_in_bnk
    BEQ @RET_end
    @lz:
        ; reset lz decoding
        JSR lz_init
        ; async lz_decode()
        ora_adr txt_flags, #TXT_FLAG_LZ
    @RET_end:
    RTS
