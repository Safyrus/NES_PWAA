    ; shake
    LDA shake_timer
    bze @shake_end
        ; update timer
        DEC shake_timer
        ; shake on the x axis
        LSR
        AND #$03
        STA scroll_x
        ; update sprites
        LDY #$03
        for_x @shake_spr, #0
            LDA spr_x_buf, X
            sub scroll_x
            STA OAM, Y
            ; next
            INY
            INY
            INY
            INY
        to_x_inc @shake_spr, #64
    @shake_end:

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

    ; sprite flickering effect
    LDX #(RES_SPR*4)
    LDY #$FC
    @sprite_fliker_loop:
        ; byte 0
        LDA OAM, Y
        PHA
        LDA OAM, X
        STA OAM, Y
        PLA
        STA OAM, X
        INX
        INY
        ; byte 1
        LDA OAM, Y
        PHA
        LDA OAM, X
        STA OAM, Y
        PLA
        STA OAM, X
        INX
        INY
        ; byte 2
        LDA OAM, Y
        PHA
        LDA OAM, X
        STA OAM, Y
        PLA
        STA OAM, X
        INX
        INY
        ; byte 3
        LDA OAM, Y
        PHA
        LDA OAM, X
        STA OAM, Y
        PLA
        STA OAM, X
        INX
        TYA
        sub #3+4
        TAY
        ; next
        CPX #$80 - (RES_SPR*2)
        blt @sprite_fliker_loop

    LDY #$3F
    for_x @sprite_fliker_buf, #RES_SPR
        LDA spr_x_buf, X
        STA tmp
        LDA spr_x_buf, Y
        STA spr_x_buf, X
        LDA tmp
        STA spr_x_buf, Y
        ; next
        DEY
    to_x_inc @sprite_fliker_buf, #32
    @sprite_fliker_end:
