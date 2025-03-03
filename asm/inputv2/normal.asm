input_normal:
    ; if button A
    LDA buttons_1
    AND #BTN_A
    BEQ :+
    ; and dialog is waiting for input
    LDA text_speed
    BNE :+
        ; restore text speed
        JSR restore_text_speed
        ; and reset dialog box
        JSR dialog_reset
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
        ; change to court record
        JSR btn_open_cr
    :

    ; if LEFT is pressed
    LDA buttons_1
    AND #BTN_SELECT
    BEQ :+
    ; and testimony
        ; go to previous dialog
    :

    ; if RIGHT is pressed
    LDA buttons_1
    AND #BTN_SELECT
    BEQ :+
    ; and testimony
        ; go to next dialog
    :

    ; if DOWN is pressed
    LDA buttons_1
    AND #BTN_SELECT
    BEQ :+
    ; and testimony
    ; and can 'hold it'
        ; 'hold it'
    :

    ; return
    RTS


btn_open_cr:
    ; input_mode = IM_CR
    LDA #IM_CR
    STA input_mode
    ; cr_flag.open = true
    LDA cr_flag
    ORA #CR_FLAG_OPEN
    STA cr_flag
    ; display court record
    ; return
    JMP display_cr
