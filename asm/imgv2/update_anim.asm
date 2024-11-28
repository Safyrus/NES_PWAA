update_anim:
    ; --- if anim is playing ---
    ; if cur_chr == 0
    LDA cur_chr+0
    BNE :+
    LDA cur_chr+1
        ; return
        BEQ @return
    :

    ; --- countdown ---
    ; if anim_timer > 0
    LDA anim_timer
    BEQ :+
        ; anim_timer--
        DEC anim_timer
        ; return
        JMP @return
    :

    ; --- update ---
    ; mmc5_bnk (for anim_buf)
    LDA #IMG_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; img_idx, time = anim_buf[anim_idx]
    LDY anim_idx
    LDA ANIM_BUF_ADR+2, Y
    ; anim_timer = time
    STA anim_timer
    ; display_chr(img_idx)
    LDA ANIM_BUF_ADR+0, Y
    TAX
    LDA ANIM_BUF_ADR+1, Y
    TAY
    JSR display_chr

    ; --- next anim ---
    ; anim_idx++
    LDA anim_idx
    add #$03
    ; if anim_idx >= anim_size
    CMP anim_size
    blt :+
        ; anim_idx = 0
        LDA #$00
    :
    STA anim_idx

    ; return
    @return:
    RTS
