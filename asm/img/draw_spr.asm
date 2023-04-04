img_spr_clear:
    push_ax

    ; clear sprites
    LDA #$FF
    for_x @clear, #0
        STA OAM, X
    to_x_inc @clear, #0

    TXA
    for_x @clear_buf, #0
        STA spr_x_buf, X
    to_x_inc @clear_buf, #64

    pull_ax
    RTS


img_spr_draw:
    pushregs

    JSR img_spr_clear
    ; set pointer to sprite data    
    sta_ptr tmp+2, IMG_CHR_BUF_SPR

    ; set sprite bank
    mov MMC5_CHR_BNK3, img_spr_b

    ; draw sprites
    mov tmp+0, #0 ; counter_y
    TAY ; STA counter_size
    LDX #(RES_SPR*4) ; OAM ptrx
    @loop_y:
        LDA #$00
        STA tmp+1 ; counter_x
        @loop_x:
            ; if it is a sprite
            LDA (tmp+2), Y
            bze @continue
            ; set y position
            LDA tmp+0
            shift ASL, 4
            add img_spr_y
            SBC #$00
            STA OAM, X
            INX
            ; set tile
            LDA (tmp+2), Y
            ASL
            STA OAM, X
            INX
            ; set attributes
            LDA #%00000000
            STA OAM, X
            INX
            ; set x position
            LDA tmp+1
            shift ASL, 3
            add img_spr_x
            STA OAM, X
            STA tmp+4
            ;
            TXA
            PHA
            LSR
            LSR
            TAX
            LDA tmp+4
            STA spr_x_buf, X
            PLA
            TAX
            INX
            ; continue
            @continue:
            ; counter_size += 1
            INY
            INC tmp+1 ; counter_x
            LDA tmp+1
            CMP img_spr_w
            BNE @loop_x
        ; continue
        INC tmp+0 ; counter_y
        CPY img_spr_count
        blt @loop_y
    
    @end:
    pullregs
    RTS
