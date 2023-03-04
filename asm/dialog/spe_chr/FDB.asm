; case FDB
@FDB:
    ; set flag to wait for user input to continue
    ; and set force flag to ignore player input
    ora_adr txt_flags, #(TXT_FLAG_WAIT + TXT_FLAG_FORCE)
    RTS
