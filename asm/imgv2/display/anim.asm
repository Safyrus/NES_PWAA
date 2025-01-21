; X = anim idx (lo)
; Y = anim idx (hi)
display_anim:
    @adr = tmp+0
    ; --------
    ; stop current anim
    ; --------
    ; cur_chr = <0
    mov cur_chr+1, #$FF
    ; save XY
    TYA
    PHA
    TXA
    PHA

    ; --------
    ; fetch anim
    ; --------
    ; anim_adr = fetch_anim(anim_idx)
    JSR fetch_anim

    ; --------
    ; copy(anim_buf,anim_adr)
    ; --------
    ; mmc5_bnk (for anim_buf)
    LDA #IMG_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; Y = adr[0] ; anim byte size
    LDY #$00
    LDA (@adr), Y
    TAY
    ; anim_size = Y - 1
    DEY
    STY anim_size
    ; for Y
    @copy:
        ; anim_buf[Y] = adr[Y+1]
        LDA (@adr), Y
        STA ANIM_BUF_ADR-1, Y
        ; continue
        DEY
        BNE @copy

    ; --------
    ; reset anim
    ; --------
    ; cur_chr = anim_idx (by restoring XY)
    PLA
    STA cur_chr+0
    PLA
    STA cur_chr+1
    ; anim_timer = 0
    LDA #$00
    STA anim_timer
    ; anim_idx = 0
    STA anim_idx

    ; return
    RTS
