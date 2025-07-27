input_act:
    ; --------
    ; update choice sprite
    ; --------
    ; X = res_oam
    LDX res_oam
    ; res_oam += 4
    TXA
    add #$04
    STA res_oam
    ; act_select * 8
    LDA act_select
    ASL
    ASL
    ASL
    ; OAM[X].y = $40 + act_select * 8
    add #$40
    STA OAM, X
    ; OAM[X].x = $10
    LDA #$10
    STA OAM+3, X
    ; OAM[X].t = ACT_SPR_TILE + get_res_bnk(SPE_BNK)
    LDA #SPE_BNK
    JSR get_res_bnk
    ORA #ACT_SPR_TILE
    STA OAM+1, X
    ; OAM[X].a = ACT_SPR_ATR
    LDA #ACT_SPR_ATR
    STA OAM+2, X

    ; --------
    ; input
    ; --------
    ; if left | up
    LDA buttons_1
    AND #BTN_LEFT|BTN_UP
    BEQ :++
        ; act_select--
        DEC act_select
        ; if act_select < 0
        BPL :+
            ; act_select = act_nchoice-1
            LDX act_nchoice
            DEX
            STX act_select
        :
    :
    ; if right | down
    LDA buttons_1
    AND #BTN_RIGHT|BTN_DOWN
    BEQ :++
        ; act_select++
        INC act_select
        ; if act_select >= max_choice
        LDA act_select
        CMP act_nchoice
        blt :+
            ; act_select = 0
            LDA #$00
            STA act_select
        :
    :
    ; if A
    LDA buttons_1
    AND #BTN_A
    BEQ :+
        ; text_jump(act_buf[act_select])
        LDA act_select
        STA MMC5_MUL_A
        LDA #ACT_ONE_CHOICE_SIZE
        STA MMC5_MUL_B
        LDX MMC5_MUL_A
        LDA act_buf+0, X
        STA jmp_buf+0
        LDA act_buf+1, X
        STA jmp_buf+1
        LDA act_buf+2, X
        STA jmp_buf+2
        JSR text_jump
        ; input_mode = IM_NORMAL
        LDA #IM_NORMAL
        STA input_mode
        ; disable act
        LDA #$00
        STA act_nchoice
        ; restore chr
        mov new_chr+0, sav_chr+0
        mov new_chr+1, sav_chr+1
        mov sav_chr+1, #$FF
        ; disable midbox
        and_adr effect_flags, #$FF-EFFECT_FLAG_MIDBOX
        ; undisplay act box
        JSR update_midbox
        ; restore text speed
        JSR restore_text_speed
        ; reset dialog box
        JSR dialog_reset
    :
    ; if B
    LDA buttons_1
    AND #BTN_B
    BEQ :+
        ; TODO
        ; if act_depth > 0
            ; go back one act before
    :

    ; return
    RTS
