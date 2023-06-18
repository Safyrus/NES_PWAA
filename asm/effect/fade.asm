fade:
    ; fade
    LDA fade_timer
    bze @fade_end
        ; offset = fade_timer / (FADE_TIME/5)
        LDX #(FADE_TIME/5)
        STX tmp
        JSR div
        ; 
        ; if fade out
        LDA effect_flags
        AND #EFFECT_FLAG_FADE
        bnz @fade_flag_end
            ; then offset = 5 - offset
            STX tmp
            LDA #$05
            sub tmp
            TAX
        @fade_flag_end:
        ;
        TXA
        ; offset *= 16
        shift ASL, 4
        STA tmp

        ; change tiles colors
        LDX #$09
        @fade_loop_tiles:
            ; color - offset
            LDA img_palettes, X
            sub tmp
            BCS @fade_tiles_set
            ; set color
            @fade_tiles_black:
                LDA #$0F
            @fade_tiles_set:
            STA palettes, X
            ; continue
            DEX
            BPL @fade_loop_tiles

        ; change sprites colors
        LDX #$02
        @fade_loop_spr:
            ; color - offset
            LDA img_palette_3, X
            sub tmp
            BCS @fade_spr_set
            ; set color
            @fade_spr_black:
                LDA #$0F
            @fade_spr_set:
            STA palettes+13, X
            ; continue
            DEX
            BPL @fade_loop_spr

        ; decrease fade counter
        DEC fade_timer
    @fade_end:
