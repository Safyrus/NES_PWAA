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
    ; buf_lo  = $??00
    LDA #$00
    STA tmp+2
    ; buf_hi  = $??00
    STA tmp+6
    ; spr_buf
    STA tmp+8
    LDA #>IMG_CHR_SPR
    STA tmp+9
    ; bnk_buf
    mov tmp+4, #<(spr_bnks-1)
    mov tmp+5, #>(spr_bnks-1)
    ; palette
    mov tmp+10, #<img_tmp_pals
    mov tmp+11, #>img_tmp_pals
    ; set RAM bank
    mov mmc5_banks+0, #IMG_BUF_BNK
    STA MMC5_RAM_BNK
    ; disable sprites
    ora_adr img_flag, #IMG_FLAG_UNSPRITE
    ; snif_decode(in, bkg_lo, bnk_buf, bkg_hi, spr_buf, palette)
    JSR snif_decode

    ; update and return
    JMP call_update_img
