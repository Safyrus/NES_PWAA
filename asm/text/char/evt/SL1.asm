EVT_SL1:
    ; b = read_char()
    JSR read_char
    ; scroll_img = b
    STA scroll_img+0
    LDA #$00
    STA scroll_img+1
    ; scroll_state = SCROLL_STATE_LOAD1
    LDA #SCROLL_STATE_LOAD1
    STA scroll_state
    ; return
    RTS
