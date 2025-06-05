change_name:
    @pos = text_name

    ; --------
    ; remove last name
    ; --------
    ; x = res_oam
    LDA #$FF
    LDX res_oam
    @remove:
        ; remove sprite[x]
        STA OAM, X
        ; continue
        DEX
        DEX
        DEX
        DEX
        BNE @remove
    ; res_oam = 0
    STX res_oam
    ; cur_bnks[7] = spr_bnks[7]
    LDA spr_bnks+7
    STA cur_bnks+7

    ; if no name to display
    LDA text_name
        ; return
        BMI @ret

    ; --------
    ; display new name
    ; --------
    ; push name
    PHA
    TAX
    ; fetch name size
    LDA names_list+1, X
    sub names_list, X
    TAY
    ; res_oam = size*4
    ASL
    ASL
    STA res_oam
    ; fetch name tile
    LDA names_list, X
    TAY
    ; cur_bnks[7] = tile >> 6
    ASL
    ASL
    LDA #$02
    ADC #$00
    STA cur_bnks+7
    ; tile |= $C0
    TYA
    ORA #$C0
    TAY
    ; pos = NAME_X_POS
    LDA #NAME_X_POS
    STA @pos
    ; for name size
    LDX #$00
    @display:
        ; sprite.y = NAME_Y_POS
        LDA #NAME_Y_POS
        STA OAM+0, X
        ; sprite.t = tile
        TYA
        STA OAM+1, X
        ; tile++
        INY
        ; sprite.a = NAME_ATR
        LDA #NAME_ATR
        STA OAM+2, X
        ; sprite.x = pos
        LDA @pos
        STA OAM+3, X
        ; pos += 8
        add #$08
        STA @pos
        ; continue
        INX
        INX
        INX
        INX
        CPX res_oam
        BNE @display
    ;
    pull text_name

    ; return
    @ret:
    RTS
