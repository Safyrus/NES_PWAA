EVT_CRF:
    ; if not cr_flag.open
    LDA cr_flag
    AND #CR_FLAG_OPEN
    BNE :+
        ; simulate button press
        ; for opening court record
        ; return
        JMP btn_open_cr
    :
    ; return
    RTS
