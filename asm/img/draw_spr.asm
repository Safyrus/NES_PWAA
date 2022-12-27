
img_spr_draw:
    pushregs

    ; clear sprites
    LDA #$FF
    LDX #$00
    @clear:
        STA OAM, X
        ; continue
        INX
        BNE @clear

    ; set pointer to sprite data    
    LDA #<(MMC5_RAM+$600)
    STA tmp+2
    LDA #>(MMC5_RAM+$600)
    STA tmp+3

    ; set sprite bank
    LDA img_spr_b
    LSR
    STA MMC5_CHR_BNK7

    ; draw sprites
    LDA #$00
    TAY ; STA counter_size
    TAX ; OAM ptrx
    STA tmp+0 ; counter_y
    @loop_y:
        LDA #$00
        STA tmp+1 ; counter_x
        @loop_x:
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
            ; counter_size += 1
            INY
            ; continue
            INC tmp+1 ; counter_x
            LDA tmp+1
            CMP img_spr_w
            BNE @loop_x
        ; continue
        INC tmp+0 ; counter_y
        CMP img_spr_count
        BNE @loop_y
    
    @end:
    pullregs
    RTS
