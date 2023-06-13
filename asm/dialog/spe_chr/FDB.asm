; case FDB
FDB:
    ; set flag to wait for user input to continue
    ; and set force flag to ignore player input
    ora_adr txt_flags, #(TXT_FLAG_WAIT + TXT_FLAG_FORCE)
    ; clear TXT_FLAG_SKIP
    and_adr txt_flags, #($FF-TXT_FLAG_SKIP)
    RTS
