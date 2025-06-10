input_normal:
    ; if button A
    LDA buttons_1
    AND #BTN_A
    BEQ :+
    ; and dialog is waiting for input
    LDA text_speed
    BNE :+
        @next_dialog:
        ; restore text speed
        JSR restore_text_speed
        ; and reset dialog box
        ; return
        JMP dialog_reset
    :

    ; if B is pressed
    LDA buttons_1
    AND #BTN_B
    BEQ :+
    ; and dialog is not waiting for input
    LDA text_speed
    BEQ :+
        ; then we are skipping dialogs
        ; save text speed
        JSR save_text_speed
        ; and set it to max
        mov text_speed, #MAX_TXT_SPD
    :

    ; if SELECT is pressed
    LDA buttons_1
    AND #BTN_SELECT
    BEQ :+
    ; and cr_flag.access
    LDA cr_flag
    AND #CR_FLAG_ACCESS
    BEQ :+
    ; and dialog is waiting for input
    LDA text_speed
    BNE :+
        ; change to court record
        ; return
        JMP btn_open_cr
    :


    ; if testimony not activated
    LDA cr_flag
    AND #CR_FLAG_HOLD
        ; return
        BEQ @ret
    ; if dialog is not waiting for input
    LDA text_speed
        ; return
        BNE @ret

    ; if RIGHT is pressed
    LDA buttons_1
    AND #BTN_RIGHT
        ; go to next dialog
        BNE @next_dialog

    ; if DOWN is pressed
    LDA buttons_1
    AND #BTN_DOWN
    BEQ :+
        ; jump to 'hold it'
        mov jmp_buf+0, cr_hold_jmp+0
        mov jmp_buf+1, cr_hold_jmp+1
        mov jmp_buf+2, cr_hold_jmp+2
        JSR text_jump
        ; next dialog
        JMP @next_dialog
    :

    ; if LEFT is pressed
    LDA buttons_1
    AND #BTN_LEFT
    BEQ :++++
    ; and can go back to previous dialog
    LDA cr_hold_jmp+JMPADR_POS_NEXT
    AND #JMPADR_MASK_NEXT
    BNE :++++
        ; decrease dialog_stack_ptr
        DEC dialog_stack_ptr
        BPL :+
            LDA #DIALOG_STACK_SIZE-1
            STA dialog_stack_ptr
        :
        DEC dialog_stack_ptr
        BPL :+
            LDA #DIALOG_STACK_SIZE-1
            STA dialog_stack_ptr
        :
        ; text pointer = previous dialog
        LDX dialog_stack_ptr
        LDA dialog_stack_lo, X
        STA txt_ptr+0
        LDA dialog_stack_hi, X
        STA txt_ptr+1
        LDA dialog_stack_bnk, X
        LDA saved_txt_bnk
        CMP lz_idx
        BEQ :+
            STA lz_idx
            JSR lz_decode
        :
        ; restore text speed
        JSR restore_text_speed
        ; and reset dialog box
        ; return
        JMP dialog_reset
    :

    ; return
    @ret:
    RTS


btn_open_cr:
    ; input_mode = IM_CR
    LDA #IM_CR
    STA input_mode
    ; cr_flag.open = true
    LDA cr_flag
    ORA #CR_FLAG_OPEN
    STA cr_flag
    ; save dialog box variables
    mov saved_text_speed, text_speed
    mov saved_text_font, text_font
    mov saved_text_color, text_color
    mov saved_text_lb_offset, text_lb_offset
    mov saved_evi_off_x, evi_off_x
    mov saved_evi_off_y, evi_off_y
    mov saved_txt_ptr+0, txt_ptr+0
    mov saved_txt_ptr+1, txt_ptr+1
    mov saved_txt_bnk, lz_idx
    ;
    mov sav_photo, cur_photo
    mov new_photo, #$FF
    ; display court record
    ; return
    JMP display_cr
