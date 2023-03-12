;
lz_init:
    push_ax
    ;
    LDX lz_idx
    ;
    LDA lz_bnk_table, X
    STA lz_in_bnk
    ;
    LDA lz_adr_table_lo, X
    STA lz_in+0
    LDA lz_adr_table_hi, X
    STA lz_in+1
    ;
    pull_ax
    RTS
