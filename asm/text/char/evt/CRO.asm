EVT_CRO:
    ; toggle cr_flag.obg
    LDA cr_flag
    EOR #CR_FLAG_OBJ
    STA cr_flag
    ; return
    RTS
