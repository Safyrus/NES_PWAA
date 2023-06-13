; case DB
DB:
    ; set flag to wait for user input to continue
    ora_adr txt_flags, #TXT_FLAG_WAIT
    ; clear TXT_FLAG_SKIP
    and_adr txt_flags, #($FF-TXT_FLAG_SKIP)
    ; clear dialog flags 'HOLDIT' 'OBJ' and 'OBJ_OK'
    push tmp
    LDA #TXT_FLG_HOLDIT
    JSR clear_dialog_flag
    LDA #TXT_FLG_OBJ
    JSR clear_dialog_flag
    LDA #TXT_FLG_OBJ_OK
    JSR clear_dialog_flag
    pull tmp
    ; return
    RTS
