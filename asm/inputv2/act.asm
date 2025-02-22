input_act:
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
        ; input_mode = IM_NORMAL
        LDA #IM_NORMAL
        STA input_mode
        ; undisplay act box (display bkg & chr)
        LDX cur_bkg
        JSR display_bkg
        LDX cur_chr+0
        LDY cur_chr+1
        JSR display_anim
        ; text_jump(act_choice[act_select])
        LDA act_select
        STA MMC5_MUL_A
        LDA #ACT_ONE_CHOICE_SIZE
        STA MMC5_MUL_B
        LDX MMC5_MUL_A
        LDA act_choice+0, X
        STA jmp_buf+0
        LDA act_choice+1, X
        STA jmp_buf+1
        LDA act_choice+2, X
        STA jmp_buf+2
        JSR text_jump
        ; restore text speed
        JSR restore_text_speed
        ; and reset dialog box
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

    ; update choice sprite

    ; return
    RTS
