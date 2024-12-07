save_text_speed:
    ; if not already saved
    LDA text_prev_speed
    BNE :+
        ; save text speed
        mov text_prev_speed, text_speed
    :
    ; return
    RTS

restore_text_speed:
    ; restore text speed
    mov text_speed, text_prev_speed
    ; clear previous speed
    mov text_prev_speed, #$00
    ; return
    RTS
