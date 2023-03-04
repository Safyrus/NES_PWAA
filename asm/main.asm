;**********
; Main
;**********

.macro MAIN_INIT
    ; render background + scroll + palette + sprites
    mov nmi_flags, #(NMI_BKG + NMI_SCRL + NMI_PLT + NMI_SPR)
    mov PPU_MASK, #(PPU_MASK_BKG + PPU_MASK_BKG8 + PPU_MASK_SPR + PPU_MASK_SPR8)
    ; enable 8*16 sprites
    LDA ppu_ctrl_val
    ORA #PPU_CTRL_SPR_SIZE
    STA ppu_ctrl_val
    STA PPU_CTRL

    ; init famistudio music
    LDX #<music_data
    LDY #>music_data
    mov MMC5_PRG_BNK1, #MUS_BNK
    JSR famistudio_init
    ; init famistudio sfx
    LDX #<sfx_data
    LDY #>sfx_data
    JSR famistudio_sfx_init

    ; set code bank
    LDA #CODE_BNK
    STA MMC5_PRG_BNK0
    STA mmc5_banks+1

    ; set dialog box palette
    mov palettes+10, #$00
    mov palettes+11, #$10
    mov palettes+12, #$30

    ; load and draw image
    JSR find_anim
    JSR frame_decode

    ; load first dialog block
    mov lz_in_bnk, #TXT_BNK
    sta_ptr lz_in, $A000
    JSR lz_decode

    ; - - - - - - - -
    ; init print variables
    ; - - - - - - - -
    ; ext value = $C0
    mov print_ext_val, #$C0
    ; print_counter = 0
    mov print_counter, #$00
    ;
    JSR read_next_dailog

    ; draw dialog box
    JSR draw_dialog_box

    ; init text read pointer
    sta_ptr txt_rd_ptr, MMC5_RAM

.endmacro

; use: A
wait_next_frame:
    ; wait for next frame to start
    @wait_vblank:
        BIT nmi_flags
        BPL @wait_vblank

    ; acknowledge nmi
    and_adr nmi_flags, #($FF-NMI_DONE)

    RTS


MAIN:

    MAIN_INIT

    @main_loop:
    JSR wait_next_frame

    ; update player inputs
    JSR update_input

    ; update choice index
    LDA max_choice
    bze @no_choice
    @a_choice:
        ; is button A-B pressed ?
        LDA buttons_1
        TAX
        AND #$C0
        bnz @choice_validate
        ; is button R-D pressed ?
        TXA
        AND #$05
        bnz @choice_plus
        ; is button L-U pressed ?
        TXA
        AND #$0A
        bnz @choice_minus
        ; no button pressed
        JMP @flags_end

        @choice_plus:
            LDX choice
            INX
            CPX max_choice
            blt @choice_plus_update
                LDX #$00
            @choice_plus_update:
            STX choice
            JMP @flags_end
        @choice_minus:
            LDX choice
            DEX
            BPL @choice_minus_update
                LDX max_choice
                DEX
            @choice_minus_update:
            STX choice
            JMP @flags_end
        @choice_validate:
            ; get choice_jmp_table index
            mov MMC5_MUL_A, choice
            mov MMC5_MUL_B, #$03
            LDX MMC5_MUL_A
            ; copy choice_jmp_table to jump buf
            LDA choice_jmp_table, X
            STA txt_jump_buf+0
            INX
            LDA choice_jmp_table, X
            STA txt_jump_buf+1
            INX
            LDA choice_jmp_table, X
            STA txt_jump_buf+2
            ; jump to that address
            JSR read_jump
            ;
            LDA #$00
            STA max_choice
            STA choice
            JMP @flags_end
    @no_choice:
        LDA buttons_1
        AND #$C0
        bze @txt_input_no
            LDA txt_flags
            ORA #TXT_FLAG_INPUT
            STA txt_flags
            JMP @txt_input_end
        @txt_input_no:
            LDA txt_flags
            AND #($FF - TXT_FLAG_INPUT)
            STA txt_flags
        @txt_input_end:
    @flags_end:

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

    ; update graphics
    JSR frame_decode

    ; read text
    JSR read_text

    ; loop back to start of main
    JMP @main_loop
