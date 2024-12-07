DB:
    ; save text speed
    JSR save_text_speed
    ; set text speed to 0
    ; to soft lock dialogs until an input occure
    mov text_speed, #$00
    ; return
    RTS
