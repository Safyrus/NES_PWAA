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

    ; flash
    LDA flash_timer
    BNE @flash_stop
        DEC flash_timer

        LDA #$30
        for_x @flash_loop_white, #$24
            STA palettes, X
        to_x_dec @flash_loop_white, #-1
        JMP @flash_end

    @flash_stop:
        ; skip if palette are changed by a fade
        LDA effect_flags
        AND #EFFECT_FLAG_FADE
        BEQ @flash_end
        ; update palette 0-2 and background color
        for_x @flash_loop_stop, #9
            LDA img_palettes, X
            STA palettes, X
        to_x_dec @flash_loop_stop, #-1
        ; update palette 3
        mov palettes+13, img_palette_3+0
        mov palettes+14, img_palette_3+1
        mov palettes+15, img_palette_3+2
    @flash_end:

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
