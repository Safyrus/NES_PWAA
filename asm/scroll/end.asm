scroll_end:
    ; scroll_state = SCROLL_STATE_NONE
    mov scroll_state, #SCROLL_STATE_NONE
    ; redraw last image normally
    LDX scroll_img+0
    STX new_bkg
    INX
    STX cur_bkg
    ; scroll_n_img = 0
    LDA #$00
    STA scroll_n_img
    ; return
    RTS
