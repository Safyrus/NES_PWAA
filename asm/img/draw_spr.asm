img_spr_clear:
    PHA
    TXA
    PHA

    ; clear sprites
    LDA #$FF
    LDX #$00
    @clear:
        STA OAM, X
        ; continue
        INX
        BNE @clear

    PLA
    TAX
    PLA
    RTS


img_spr_draw:
    pushregs

    JSR img_spr_clear
    ; set pointer to sprite data    
    LDA #<(MMC5_RAM+$600)
    STA tmp+2
    LDA #>(MMC5_RAM+$600)
    STA tmp+3

    ; set sprite bank
    LDA img_spr_b
    STA MMC5_CHR_BNK3

    ; draw sprites
    LDA #$00
    STA tmp+0 ; counter_y
    TAY ; STA counter_size
    LDX #(RES_SPR*4) ; OAM ptrx
    @loop_y:
        LDA #$00
        STA tmp+1 ; counter_x
        @loop_x:
            ; if it is a sprite
            LDA (tmp+2), Y
            BEQ @continue
            ; set y position
            LDA tmp+0
            ASL
            ASL
            ASL
            ASL
            CLC
            ADC img_spr_y
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
            ASL
            ASL
            ASL
            CLC
            ADC img_spr_x
            STA OAM, X
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
        BCC @loop_y
    
    @end:
    pullregs
    RTS
