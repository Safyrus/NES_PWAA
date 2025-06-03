draw_sprites:
    ; if img_flag.evispr
    LDA img_flag
    AND #IMG_FLAG_EVISPR
    BEQ :+
        ; push current bank
        push mmc5_banks+0
        ; change ram bank to the one
        ; containing evidence sprites
        mov mmc5_banks+0, #GENERAL_BNK
        STA MMC5_RAM_BNK
    :

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
        ; s.y -= scroll_y
        sub scroll_y
        ; s.y += spr_off_y
        add spr_off_y
        ; if s.y >= $89
        PHA
        CMP #$89
        blt @name_end
        ; and if name is displayed
        LDA text_name
        BMI @name_end
            @skip:
            ; Y++
            INY
            INY
            INY
            INY
            ; continue
            PLA
            BNE @continue
        @name_end:
        ; if s.t >= $C0
        LDA IMG_CHR_SPR+1, Y
        CMP #$C0
        blt :+
        ; and s.t & $01
        LSR
            ; skip this sprite
            BCS @skip
        :
        ; OAM[X] = s
        ; y
        PLA
        STA OAM+0, X
        ; tile
        LDA IMG_CHR_SPR+1, Y
        STA OAM+1, X
        ; atr
        LDA IMG_CHR_SPR+2, Y
        STA OAM+2, X
        ; x
        LDA IMG_CHR_SPR+3, Y
        sub scroll_x
        add spr_off_x
        STA OAM+3, X
        ; X++
        TXA
        CLC
        ADC #$04
        TAX
        ; if X == 0 (overflow/OAM full)
            ; break and skip next while loop
            BEQ @while_end
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
    @while_end:
    ; draw_sprite_idx = Y
    STY draw_sprite_idx

    ; Y = 7
    LDY #$07
    ; if last bank reserved
    LDA res_oam
    BEQ :+
        ; Y--
        DEY
    :
    ; for Y to 0 (included)
    @update_bnks:
        ; if img_flag.evispr
        LDA img_flag
        AND #IMG_FLAG_EVISPR
        BEQ :+
            ; A = evi_bnks[Y]
            LDA evi_bnks, Y
            JMP :++
        ; else
        :
            ; A = spr_bnks[Y]
            LDA spr_bnks, Y
        :
        ; MMC5_CHR_BNK[Y] = A
        STA MMC5_CHR_BNK0, Y
        ; continue
        DEY
        BPL @update_bnks

    ; if img_flag.evispr
    LDA img_flag
    AND #IMG_FLAG_EVISPR
    BEQ :+
        ; restore bank
        pull mmc5_banks+0
        STA MMC5_RAM_BNK
    :

    ; return
    RTS
