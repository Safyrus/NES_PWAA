; X = bkg idx
display_bkg:
    ; --------
    ; fetch background
    ; --------
    ; in = fetch_img(X)
    LDY #$00
    JSR fetch_img

    ; --------
    ; decode image
    ; --------
    ; in = tmp+0 (already set with fetch)
    ; bkg_lo
    ; bkg_hi
    LDA #$60
    STA tmp+2
    STA tmp+6
    mov tmp+3, #>(IMG_BKG_LO_ADR+$60)
    mov tmp+7, #>(IMG_BKG_HI_ADR+$60)
    ; bnk_buf
    mov tmp+4, #<$700
    mov tmp+5, #>$700
    ; spr_buf
    mov tmp+8, #<$6C00
    mov tmp+9, #>$6C00
    ; palette
    mov tmp+10, #<palettes
    mov tmp+11, #>palettes
    ; set RAM bank
    mov MMC5_RAM_BNK, #IMG_BUF_BNK
    STA mmc5_banks+0
    ; snif_decode(in, bkg_lo, bnk_buf, bkg_hi, spr_buf, palette)
    JSR snif_decode

    ; --------
    ; update
    ; --------
    ; if dialog box displayed
    BIT effect_flags
    BPL :+
        ; update all
        JSR update_all_image_no_db
        JMP :++
    ; else
    :
        ; update all except dialog box space
        JSR update_all_image
    :

    ; return
    RTS
