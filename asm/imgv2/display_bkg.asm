; X, Y = chr idx
display_chr:
    ; bkg_lo
    ; bkg_hi
    mov tmp+3, #>(IMG_CHR_LO_ADR+$60)
    mov tmp+7, #>(IMG_CHR_HI_ADR+$60)
    JMP display_img

; X = bkg idx
display_bkg:
    ; bkg_lo
    ; bkg_hi
    mov tmp+3, #>(IMG_BKG_LO_ADR+$60)
    mov tmp+7, #>(IMG_BKG_HI_ADR+$60)
    ; Y = 0
    LDY #$00

; X, Y = img idx
; tmp+2 = bkg_lo
; tmp+6 = bkg_hi
display_img:
    ; --------
    ; fetch background
    ; --------
    ; in = fetch_img(X)
    JSR fetch_img

    ; --------
    ; decode image
    ; --------
    ; in = tmp+0 (already set with fetch)
    ; buf_lo  = $??60
    LDA #$60
    STA tmp+2
    ; buf_hi  = $??60
    STA tmp+6
    ; bnk_buf
    mov tmp+4, #<(MMC5_CHR_BNK0-1)
    mov tmp+5, #>(MMC5_CHR_BNK0-1)
    ; spr_buf
    LDA #$00
    STA tmp+8
    LDA #$7C
    STA tmp+9
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
