; update palettes
update_palettes:
    pushregs

    ; if lf_spd != 0
    LDA lf_spd+1
    BNE @if
    LDA lf_spd+0
    BEQ @fi
    @if:
        ; lf_cur += lf_spd
        CLC
        LDA lf_spd+0
        ADC lf_cur+0
        STA lf_cur+0
        LDA lf_spd+1
        ADC lf_cur+1
        STA lf_cur+1
        ; if lf_cur.light == lf_obj.light
        LDA lf_cur+1
        AND #LF_LIGHT
        CMP lf_obj
        BNE @fi
            ; lf_spd = 0
            LDA #$00
            STA lf_spd+0
            STA lf_spd+1
            ; lf_cur.step = 0
            STA lf_cur+0
            LDA lf_cur+1
            AND #LF_LIGHT
            STA lf_cur+1
    @fi:

    ; X = lf_cur.light
    LDA lf_cur+1
    AND #LF_LIGHT
    TAX
    ; for 3*8+1
    LDY #3*8
    @for:
        ; A = img_pals[Y] + X
        TXA
        CLC
        ADC img_pals, Y
        ; if A < 0
        BPL :+
            ; A = black
            LDA #$0F
            BNE @set
        :
        ; elif A >= $40
        CMP #$40
        blt @set
            ; A = white
            LDA #$30
        @set:
        ; palettes[Y] = A
        STA palettes, Y
        ; continue
        DEY
        BPL @for

    ; return
    pullregs
    RTS
