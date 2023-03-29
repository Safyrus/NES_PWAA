; case DB
@DB:
    ; set flag to wait for user input to continue
    ora_adr txt_flags, #TXT_FLAG_WAIT
    ; clear TXT_FLAG_SKIP
    and_adr txt_flags, #($FF-TXT_FLAG_SKIP)
    RTS
