update_light_spd:
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


LF_SPD_8FRAME:
.word $1000
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

LF_SPD_FRAME:
.word $1000
.word $1000
.word $0800
.word $0555
.word $0400
.word $0333
.word $02aa
.word $0249
.word $0200
.word $01c7
.word $0199
.word $0174
.word $0155
.word $013b
.word $0124
.word $0111
