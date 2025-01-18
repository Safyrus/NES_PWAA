FAD:
    ; set number of char to read to 0
    LDA #$00
    STA txt_vars+0
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

    ; lf_tmp = 0
    LDA #$00
    STA lf_tmp+0
    STA lf_tmp+1
    ; dif = lf_obj - lf_cur
    LDA lf_obj
    sub lf_cur+1
    ; if dif == 0
        ; return
        BEQ @ret
    ; if dif < 0
    BPL :+
        ; dif *= -1
        EOR #$F0
        add #$10
        ; neg = true
        DEC lf_tmp+0
    :
    ; dif >>= 4
    shift LSR, 4
    TAY
    ; lf_spd = LF_SPD2STEP[X]
    LDA LF_SPD2STEP, X
    STA lf_spd+0
    LDA LF_SPD2STEP+1, X
    STA lf_spd+1
    ; if neg
    LDA lf_tmp+0
    BEQ :+
        ; lf_spd *= -1
        LDA lf_spd+0
        EOR #$FF
        CLC
        ADC #$01
        STA lf_spd+0
        LDA lf_spd+1
        EOR #$FF
        ADC #$00
        STA lf_spd+1
        ;
        INC lf_tmp+0
    :
    ; lf_spd *= dif
    @mul:
        ; lf_tmp += lf_spd
        CLC
        LDA lf_tmp+0
        ADC lf_spd+0
        STA lf_tmp+0
        LDA lf_tmp+1
        ADC lf_spd+1
        STA lf_tmp+1
        ; continue
        DEY
        BNE @mul
    ;
    mov lf_spd+0, lf_tmp+0
    mov lf_spd+1, lf_tmp+1
    
    ; return
    @ret:
    RTS

LF_SPD2STEP:
.word $0FFF
.word $0200
.word $0100
.word $00aa
.word $0080
.word $0066
.word $0055
.word $0049
.word $0038
.word $0033
.word $002e
.word $002a
.word $0027
.word $0024
.word $0022
