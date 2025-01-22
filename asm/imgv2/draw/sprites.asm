draw_sprites:
    ; X = res_oam
    LDX res_oam
    ; Y = draw_sprite_idx
    LDY draw_sprite_idx
    ; for chr_spr
    @for:
        ; s = chr_spr[y]
        ; if s.y >= $F0
        LDA IMG_CHR_SPR+0, Y
        CMP #$F0
        blt :+
            ; if y == 0
            TYA
                ; break
                BEQ @break
            ; Y = 0
            LDY #$00
            ; continue
            BEQ @continue
        :
        ; OAM[X] = s
        sub scroll_y
        STA OAM+0, X
        LDA IMG_CHR_SPR+1, Y
        STA OAM+1, X
        LDA IMG_CHR_SPR+2, Y
        STA OAM+2, X
        LDA IMG_CHR_SPR+3, Y
        sub scroll_x
        STA OAM+3, X
        ; X++
        TXA
        CLC
        ADC #$04
        TAX
        ; if X == 0 (overflow/OAM full)
            ; break
            BEQ @break
        ; Y++
        TYA
        ADC #$04
        TAY
        @continue:
        ; if Y == draw_sprite_idx
        CPY draw_sprite_idx
            ; break
            BNE @for
    @break:

    ; write empty sprite to remaining OAM locations
    LDA #$FF
    @while:
        ; OAM[X].y = $FF
        STA OAM, X
        ; X++
        INX
        INX
        INX
        INX
        ; continue
        BNE @while

    ; draw_sprite_idx = Y
    STY draw_sprite_idx

    LDY #$07
    @update_bnks:
        LDA spr_bnks, Y
        STA MMC5_CHR_BNK0, Y
        DEY
        BPL @update_bnks

    ; return
    RTS
