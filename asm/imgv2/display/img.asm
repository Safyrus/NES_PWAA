; X, Y = img idx
; tmp+2 = bkg_lo
; tmp+4 = spr_bnk
; tmp+6 = bkg_hi
; tmp+8 = spr
; tmp+10 = pals
; tmp+12 = ram_bnk
display_img:
    ; save bnk 0
    push mmc5_banks+1

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
    ; set RAM bank
    mov mmc5_banks+0, tmp+12
    STA MMC5_RAM_BNK
    ; disable sprites
    ora_adr img_flag, #IMG_FLAG_UNSPRITE
    ; snif_decode(in, bkg_lo, bnk_buf, bkg_hi, spr_buf, palette)
    JSR snif_decode

    ; restore bnk 0
    pull mmc5_banks+1
    STA MMC5_PRG_BNK0

    ; return
    RTS
