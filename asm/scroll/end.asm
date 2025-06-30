scroll_end:
    ; scroll_state = SCROLL_STATE_NONE
    mov scroll_state, #SCROLL_STATE_NONE
    ; redraw last image normally
    LDA scroll_img+0
    STA new_bkg
    ; reset scroll
    LDA #$00
    STA scroll_x
    STA scroll_y
    ; scroll_n_img = 0
    STA scroll_n_img
    ; return
    RTS
