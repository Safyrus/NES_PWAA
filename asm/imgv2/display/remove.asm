; X = negative index
remove_bkg:
    STX cur_bkg
    ; set image drawing flag
    ora_adr effect_flags, #EFFECT_FLAG_IMAGE
    ; disable sprites
    ora_adr img_flag, #IMG_FLAG_UNSPRITE
    ; save bank
    LDA mmc5_banks+0
    PHA
    ; set image bank
    LDA #IMG_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK

    ; clear background tiles
    LDA #$00
    TAX
    @clear_tiles:
        STA IMG_BKG_LO_ADR+$000, X
        STA IMG_BKG_LO_ADR+$100, X
        STA IMG_BKG_LO_ADR+$200, X
        STA IMG_BKG_HI_ADR+$000, X
        STA IMG_BKG_HI_ADR+$100, X
        STA IMG_BKG_HI_ADR+$200, X
        ; continue
        INX
        BNE @clear_tiles
    ; clear background color
    STA img_tmp_pals+0

    ; restore bank
    PLA
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; return
    RTS


remove_chr:
    ; cur_chr = new_chr
    mov cur_chr+0, new_chr+0
    mov cur_chr+1, new_chr+1
    ; save bank
    LDA mmc5_banks+0
    PHA
    ; set image bank
    LDA #IMG_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK

    ; clear character tiles
    LDA #$00
    TAX
    @clear_tiles:
        STA IMG_CHR_LO_ADR+$000, X
        STA IMG_CHR_LO_ADR+$100, X
        STA IMG_CHR_LO_ADR+$200, X
        STA IMG_CHR_HI_ADR+$000, X
        STA IMG_CHR_HI_ADR+$100, X
        STA IMG_CHR_HI_ADR+$200, X
        ; continue
        INX
        BNE @clear_tiles
    
    ; clear sprites
    LDA #$FF
    @clear_spr:
        STA IMG_CHR_SPR, X
        ; continue
        INX
        BNE @clear_spr

    ; restore bank
    PLA
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; return
    RTS
