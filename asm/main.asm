;**********
; Main
;**********

.macro MAIN_INIT
    ; render background + scroll + palette + sprites
    LDA #(NMI_BKG + NMI_SCRL + NMI_PLT + NMI_SPR)
    STA nmi_flags
    LDA #(PPU_MASK_BKG + PPU_MASK_BKG8 + PPU_MASK_SPR + PPU_MASK_SPR8)
    STA PPU_MASK
    ; 
    LDA ppu_ctrl_val
    ORA #PPU_CTRL_SPR_SIZE
    STA ppu_ctrl_val
    STA PPU_CTRL

    ; set dialog box palette
    LDA #$00
    STA palettes+10
    LDA #$10
    STA palettes+11
    LDA #$30
    STA palettes+12

    ; load and draw image
    LDA #IMAGE_BNK
    STA MMC5_PRG_BNK0
    JSR find_anim
    JSR frame_decode

    ; load first dialog block
    LDA #DIALOG_BNK
    STA MMC5_PRG_BNK0
    LDA #TXT_BNK
    STA lz_in_bnk
    LDA #$00
    STA lz_in+0
    LDA #$A0
    STA lz_in+1
    JSR lz_decode

    ; init text read pointer
    LDA #<MMC5_RAM
    STA txt_rd_ptr+0
    LDA #>MMC5_RAM
    STA txt_rd_ptr+1

    ; - - - - - - - -
    ; init print variables
    ; - - - - - - - -
    ; ext value = $C0
    LDA #$C0
    STA print_ext_val
    ; print_counter = 0
    LDA #$00
    STA print_counter
    ;
    JSR read_next_dailog

    ; draw dialog box
    JSR draw_dialog_box

.endmacro

; use: A
wait_next_frame:
    ; wait for next frame to start
    @wait_vblank:
        BIT nmi_flags
        BPL @wait_vblank

    ; acknowledge nmi
    LDA nmi_flags
    AND #($FF-NMI_DONE)
    STA nmi_flags

    RTS


MAIN:

    MAIN_INIT

    @main_loop:
    JSR wait_next_frame

    ; update player inputs
    JSR readjoy

    JSR frame_decode

    ; update text flags
    LDA buttons_1
    BEQ @no_input
        LDA txt_flags
        ORA #TXT_FLAG_INPUT
        STA txt_flags
        JMP @input_end
    @no_input:
        LDA txt_flags
        AND #($FF - TXT_FLAG_INPUT)
        STA txt_flags
    @input_end:

    ; shake
    LDA shake_timer
    BEQ @no_shake
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
    BEQ @fade_end
        ; find color offset
        LSR
        AND #$F0
        STA tmp

        ; reverse fade counter if fade out flag set
        LDA effect_flags
        AND #EFFECT_FLAG_FADE
        BNE @fade_flag_end
            LDA #(FADE_TIME >> 1)
            SEC
            SBC tmp
            AND #$F0
            STA tmp
        @fade_flag_end:

        ; change tiles colors
        LDX #$09
        @fade_loop_tiles:
            ; color - offset
            LDA img_palettes, X
            SEC
            SBC tmp
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
            SEC
            SBC tmp
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

    ; read text
    JSR read_text

    ; loop back to start of main
    JMP @main_loop
