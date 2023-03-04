; case DB
@DB:
    ; set flag to wait for user input to continue
    ora_adr txt_flags, #TXT_FLAG_WAIT
    RTS
