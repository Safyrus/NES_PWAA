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
    mov tmp+4, #<(spr_bnks-1)
    mov tmp+5, #>(spr_bnks-1)
    ; spr_buf
    LDA #$00
    STA tmp+8
    LDA #$7C
    STA tmp+9
    ; palette
    mov tmp+10, #<img_pals
    mov tmp+11, #>img_pals
    ; set RAM bank
    mov MMC5_RAM_BNK, #IMG_BUF_BNK
    STA mmc5_banks+0
    ; disable sprites
    ora_adr img_flag, #IMG_FLAG_UNSPRITE
    ; snif_decode(in, bkg_lo, bnk_buf, bkg_hi, spr_buf, palette)
    JSR snif_decode

    ; --------
    ; update
    ; --------
    ; disable MMC5 tiles updates
    ora_adr img_flag, #IMG_FLAG_UNMMC5
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
    ; re-enable MMC5 tiles updates
    and_adr img_flag, #($FF-IMG_FLAG_UNMMC5)

    ; return
    RTS
