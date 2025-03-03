EVT_CR:
    ; toggle cr_flag.access
    LDA cr_flag
    EOR #CR_FLAG_ACCESS
    STA cr_flag
    ; return
    RTS
