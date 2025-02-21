; X = evi idx
display_evi:
    ; save bnk 0 & ram
    push mmc5_banks+0
    push mmc5_banks+1

    ; --------
    ; fetch background
    ; --------
    ; in = fetch_evi(X)
    JSR fetch_evi

    ; --------
    ; decode image
    ; --------
    ; in = tmp+0 (already set with fetch)
    ; buf_lo  = $????
    ; buf_hi  = $????
    ; spr_buf
    mov tmp+8, #$00
    mov tmp+9, #>IMG_CHR_SPR
    ; bnk_buf
    mov tmp+4, #<(evi_bnks-1)
    mov tmp+5, #>(evi_bnks-1)
    ; palette
    mov tmp+10, #<evi_pals
    mov tmp+11, #>evi_pals
    ; set RAM bank
    mov mmc5_banks+0, #GENERAL_BNK
    STA MMC5_RAM_BNK
    ; disable sprites
    ora_adr img_flag, #IMG_FLAG_UNSPRITE
    ; snif_decode(in, bkg_lo, bnk_buf, bkg_hi, spr_buf, palette)
    JSR snif_decode

    ; restore bnk 0
    pull mmc5_banks+1
    STA MMC5_PRG_BNK0
    pull mmc5_banks+0
    STA MMC5_RAM_BNK

    ; return
    RTS
