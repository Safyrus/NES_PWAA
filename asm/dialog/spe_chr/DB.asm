; case DB
@DB:
    ; set flag to wait for user input to continue
    LDA txt_flags
    ORA #TXT_FLAG_WAIT
    STA txt_flags
    RTS
