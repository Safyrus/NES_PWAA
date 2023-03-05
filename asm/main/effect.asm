    ; shake
    LDA shake_timer
    bze @no_shake
        ; shake on the x axis
        LSR
        AND #$03
        STA scroll_x
        LDA shake_timer
        ; update timer
        DEC shake_timer
        JMP @shake_end
    @no_shake:
        STA scroll_x
        STA scroll_y
    @shake_end:

    ; fade
    LDA fade_timer
    bze @fade_end
        ; find color offset
        LSR
        AND #$F0
        STA tmp

        ; reverse fade counter if fade out flag set
        LDA effect_flags
        AND #EFFECT_FLAG_FADE
        bnz @fade_flag_end
            LDA #(FADE_TIME >> 1)
            sub tmp
            AND #$F0
            STA tmp
        @fade_flag_end:

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

    ; choice highlight
    LDA max_choice
    bze @choice_highlight_end
        ; wait to be in frame
        @choice_highlight_inframe:
            BIT scanline
            BVC @choice_highlight_inframe
        ; tmp = EXP_RAM + $281
        sta_ptr tmp, (MMC5_EXP_RAM+$281)

        ;
        LDX #$00
        LDY #$00
        @choice_highlight_loop:
            ;
            TXA
            CMP choice
            BNE @choice_highlight_no
            @choice_highlight_yes:
                LDA #$00
                JMP @choice_highlight_set
            @choice_highlight_no:
                LDA #$C0
            @choice_highlight_set:
            STA (tmp), Y
            ; tmp += $40
            add_A2ptr tmp, #$40
            ; next
            INX
            CPX max_choice
            BNE @choice_highlight_loop
    @choice_highlight_end:
