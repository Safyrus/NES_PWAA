input_cr:
    ; if displaying cr
    LDA text_speed
    BEQ :+
        ; return
        RTS
    :

    ; if A or DOWN
    LDA buttons_1
    AND #BTN_A|BTN_DOWN
    BEQ :+++
    ; and can present evidence
    LDA cr_flag
    AND #CR_FLAG_OBJ
    BEQ :+++
        ; set dialog_flags[EVI_FLAG_OBJ]
        LDA #EVI_FLAG_OBJ
        JSR set_dialog_flag
        ; if cr_idx == cr_correct_idx
        LDA cr_correct_idx
        CMP cr_idx
        BNE :+
            ; set dialog_flags[EVI_FLAG_OKOBJ]
            LDA #EVI_FLAG_OKOBJ
            JSR set_dialog_flag
            JMP :++
        :
            ; clear dialog_flags[EVI_FLAG_OKOBJ]
            LDA #EVI_FLAG_OKOBJ
            JSR clear_dialog_flag
        :
        ; close court record
        JSR close_cr
        ; simulate press A on dialog box
        ; and return
        JSR restore_text_speed
        JMP dialog_reset
    :

    ; if B or SELECT
    LDA buttons_1
    AND #BTN_B|BTN_SELECT
    BEQ :+
    ; and cr_flag.access
    LDA cr_flag
    AND #CR_FLAG_ACCESS
    BEQ :+
        ; close court record
        ; and return
        JMP close_cr
    :

    ; if LEFT
    LDA buttons_1
    AND #BTN_LEFT
    BEQ :+
        ; find the next evidence
        next_evi
        ; and display it
        ; and return
        JMP display_cr
    :

    ; if RIGHT
    LDA buttons_1
    AND #BTN_RIGHT
    BEQ :+
        ; find the previous evidence
        prev_evi
        ; and display it
        ; and return
        JMP display_cr
    :

    ; return
    RTS


close_cr:
    ; input_mode = IM_NORMAL
    LDA #IM_NORMAL
    STA input_mode
    ; cr_flag.open = false
    LDA cr_flag
    AND #$FF-CR_FLAG_OPEN
    STA cr_flag
    ; restore dialog box variables
    mov text_font, saved_text_font
    mov text_color, saved_text_color
    mov text_lb_offset, saved_text_lb_offset
    mov evi_off_x, saved_evi_off_x
    mov evi_off_y, saved_evi_off_y
    mov txt_ptr+0, saved_txt_ptr+0
    mov txt_ptr+1, saved_txt_ptr+1
    mov lz_idx, saved_txt_bnk
    CMP lz_idx
    BEQ :+
        JSR lz_decode
    :
    STA lz_idx
    ; undisplay court record
    ; and redisplay dialog box
    JSR remove_cr
    ;
    mov new_photo, sav_photo
    ; return
    RTS
