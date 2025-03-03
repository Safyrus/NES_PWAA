input_cr:
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
        ; input_mode = IM_NORMAL
        LDA #IM_NORMAL
        STA input_mode
        ; restore text speed
        JSR restore_text_speed
        ; and reset dialog box
        JSR dialog_reset
    :

    ; if B or SELECT
    LDA buttons_1
    AND #BTN_B|BTN_SELECT
    BEQ :+
    ; and cr_flag.access
    LDA cr_flag
    AND #CR_FLAG_ACCESS
    BEQ :+
        ; input_mode = IM_NORMAL
        LDA #IM_NORMAL
        STA input_mode
        ; cr_flag.open = false
        LDA cr_flag
        AND #$FF-CR_FLAG_OPEN
        STA cr_flag
        ; undisplay court record
        ; and redisplay dialog box
        JSR remove_cr
    :

    ; if LEFT
    LDA buttons_1
    AND #BTN_LEFT
    BEQ :+
        ; find the next evidence
        next_evi
        ; and display it
        JSR display_cr
    :

    ; if RIGHT
    LDA buttons_1
    AND #BTN_RIGHT
    BEQ :+
        ; find the previous evidence
        prev_evi
        ; and display it
        JSR display_cr
    :

    ; return
    RTS
