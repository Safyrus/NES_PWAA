FLH:
    ; lf_obj = lf_cur
    LDA lf_cur+1
    STA lf_obj
    ; read argument
    JSR read_char
    ; lf_cur = arg.light
    TAX
    AND #LF_LIGHT
    STA lf_cur+1
    LDA #$00
    STA lf_cur+0
    TXA
    ; X = arg.spd << 1
    AND #$FF-LF_LIGHT
    ASL
    TAX
    ; lf_spd = LF_SPD_FRAME[X]
    LDA LF_SPD_FRAME, X
    STA lf_spd+0
    LDA LF_SPD_FRAME+1, X
    STA lf_spd+1
    ;
    JMP update_light_spd
