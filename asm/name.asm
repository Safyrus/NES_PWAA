change_name:
    @pos = name_tmp

    ; if no name to display
    LDA text_name
    BPL :+
        ; return
        RTS
    :
    ; if hp bar displayed
    LDA hp_state
    CMP #HP_STATE_HIDE
        ; return
        BNE @ret
    ; if dialog box hidden
    LDA effect_flags
    AND #EFFECT_FLAG_DIALOG
        ; return
        BEQ @ret

    ;
    mov img_tmp_pals+(7*3)+1, #NAME_COL_1
    mov img_tmp_pals+(7*3)+2, #NAME_COL_2
    mov img_tmp_pals+(7*3)+3, #NAME_COL_3
    ; copy_palettes()
    JSR copy_palettes
    ; update_palettes()
    JSR update_palettes

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
    ROL
    ROL
    ROL
    AND #$03
    JSR get_res_bnk
    TAY
    ; tile |= b << 6
    ROR
    ROR
    ROR
    AND #$C0
    ORA name_tmp
    TAY
    ; pos = NAME_X_POS
    mov @pos, #NAME_X_POS
    ; for size
    @display:
        ; OAM[spr_idx].y = NAME_Y_POS
        LDA #NAME_Y_POS
        sub scroll_y
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
        sub scroll_x
        STA OAM+3, X
        ; pos += 8
        LDA @pos
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
