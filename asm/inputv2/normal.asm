input_normal:
    ; if button A or B pressed
    LDA buttons_1
    AND #BTN_A+BTN_B
    BEQ :+++
        ; if dialog is waiting for input
        LDA text_speed
        BNE :+
            ; restore text speed
            JSR restore_text_speed
            JMP :++
        ; else we are skipping dialogs
        :
            ; save text speed
            JSR save_text_speed
            ; and set it to max
            mov text_speed, #MAX_TXT_SPD
        :
    :

    ; return
    RTS
