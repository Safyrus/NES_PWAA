change_name:
    @pos = name_tmp

    ; if no name to display
    LDA text_name
        ; return
        BMI @ret

    ; --------
    ; display new name
    ; --------
    ; size = fetch name size
    LDY text_name
    LDA names_list+1, Y
    sub names_list, Y
    ; spr_idx = res_oam
    LDX res_oam
    ; res_oam += size*4
    ASL
    ASL
    add res_oam
    STA res_oam
    ; tile = fetch name tile
    LDA names_list, Y
    STA name_tmp
    ; b = get_res_bnk(tile >> 6)
    LSR
    LSR
    LSR
    LSR
    LSR
    LSR
    JSR get_res_bnk
    TAY
    ; tile |= b << 6
    LSR
    CLC
    ROR
    ROR
    ROR
    ORA name_tmp
    STA name_tmp
    ; tile |= b >> 2
    TYA
    LSR
    LSR
    ORA name_tmp
    TAY
    ; pos = NAME_X_POS
    mov @pos, #NAME_X_POS
    ; for size
    @display:
        ; OAM[spr_idx].y = NAME_Y_POS
        LDA #NAME_Y_POS
        STA OAM+0, X
        ; OAM[spr_idx].t = tile
        TYA
        STA OAM+1, X
        ; tile++
        INY
        ; OAM[spr_idx].a = NAME_ATR
        LDA #NAME_ATR
        STA OAM+2, X
        ; OAM[spr_idx].x = pos
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

    ; return
    @ret:
    RTS
