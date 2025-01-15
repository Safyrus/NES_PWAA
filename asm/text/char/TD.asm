TD:
    ; toggle dialog box
    eor_adr effect_flags, #EFFECT_FLAG_PAL_SPLIT
    ; set IMG bank
    LDA #IMG_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; update dialog box
    JSR update_dialog
    ; set TEXT bank
    LDA #TEXT_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; return
    RTS
