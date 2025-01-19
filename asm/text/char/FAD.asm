FAD:
    ; read argument
    JSR read_char

    ; lf_obj = -arg.light
    TAX
    AND #LF_LIGHT
    EOR #$F0
    add #$10
    STA lf_obj
    TXA
    ; X = arg.spd << 1
    AND #$FF-LF_LIGHT
    ASL
    TAX
    ; lf_spd = LF_SPD_8FRAME[X]
    LDA LF_SPD_8FRAME, X
    STA lf_spd+0
    LDA LF_SPD_8FRAME+1, X
    STA lf_spd+1

    ;
    JMP update_light_spd
