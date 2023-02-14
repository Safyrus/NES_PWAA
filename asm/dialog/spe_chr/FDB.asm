; case FDB
@FDB:
    ; set flag to wait for user input to continue
    ; and set force flag to ignore player input
    LDA txt_flags
    ORA #(TXT_FLAG_WAIT + TXT_FLAG_FORCE)
    STA txt_flags
    RTS
