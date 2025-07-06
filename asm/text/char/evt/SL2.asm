EVT_SL2:
    ; b = read_char()
    JSR read_char
    ; scroll_img_1 = b
    STA scroll_img+1
    ; b = read_char()
    JSR read_char
    ; scroll_img_2 = b
    STA scroll_img+0
    ; scroll_state = SCROLL_STATE_LOAD2
    LDA #SCROLL_STATE_LOAD2
    STA scroll_state
    ; return
    RTS
