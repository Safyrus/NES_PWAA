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
    ; clear current and last image buffer
    TAX
    @for:
        ; buffers[X+...] = 0
        STA IMG_BUF_LO_ADR+$000, X
        STA IMG_BUF_LO_ADR+$100, X
        STA IMG_BUF_LO_ADR+$200, X
        STA IMG_BUF_HI_ADR+$000, X
        STA IMG_BUF_HI_ADR+$100, X
        STA IMG_BUF_HI_ADR+$200, X
        STA IMG_BUF2_LO_ADR+$000, X
        STA IMG_BUF2_LO_ADR+$100, X
        STA IMG_BUF2_LO_ADR+$200, X
        STA IMG_BUF2_HI_ADR+$000, X
        STA IMG_BUF2_HI_ADR+$100, X
        STA IMG_BUF2_HI_ADR+$200, X
        ; continue
        INX
        BNE @for
    ; return
    RTS
