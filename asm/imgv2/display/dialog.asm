clear_dialog:
    ; set bank
    LDA mmc5_banks+0
    PHA
    LDA #IMG_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; clear all tiles
    LDY #$00
    @clear:
        LDA #$01
        STA DB_ADR_LO, Y
        LDA #$C0
        STA DB_ADR_HI, Y
        INY
        BNE @clear
    ; draw top and bottom border
    LDY #29
    @topbot:
        LDA #DB_TILE_T
        STA DB_ADR_LO+1, Y
        LDA #DB_TILE_B
        STA DB_ADR_LO+1+(7*32), Y
        DEY
        BPL @topbot
    ; draw left side
    LDA #DB_TILE_L
    STA DB_ADR_LO+(1*32)
    STA DB_ADR_LO+(2*32)
    STA DB_ADR_LO+(3*32)
    STA DB_ADR_LO+(4*32)
    STA DB_ADR_LO+(5*32)
    STA DB_ADR_LO+(6*32)
    ; draw right side
    LDA #DB_TILE_R
    STA DB_ADR_LO+31+(1*32)
    STA DB_ADR_LO+31+(2*32)
    STA DB_ADR_LO+31+(3*32)
    STA DB_ADR_LO+31+(4*32)
    STA DB_ADR_LO+31+(5*32)
    STA DB_ADR_LO+31+(6*32)
    ; draw corners
    LDA #DB_TILE_TL
    STA DB_ADR_LO+0
    LDA #DB_TILE_TR
    STA DB_ADR_LO+31
    LDA #DB_TILE_BL
    STA DB_ADR_LO+0+(7*32)
    LDA #DB_TILE_BR
    STA DB_ADR_LO+31+(7*32)
    ; restore bank
    PLA
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; return
    RTS
