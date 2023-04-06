;**********
; Main
;**********

; use: A
wait_next_frame:
    ; wait for next frame to start
    @wait_vblank:
        BIT nmi_flags
        BPL @wait_vblank

    ; acknowledge nmi
    and_adr nmi_flags, #($FF-NMI_DONE)

    RTS

update_screen_scroll:
    PHA
    ; update high scroll
    and_adr ppu_ctrl_val, #$FE
    LDA effect_flags
    AND #EFFECT_FLAG_NT
    LSR
    LSR
    ORA ppu_ctrl_val
    STA ppu_ctrl_val
    STA PPU_CTRL
    ; update mmmc5 high upper chr bits
    LDA img_header
    AND #$03
    STA mmc5_upper_chr
    ; return
    PLA
    RTS


; X = input page
; Y = output page
cp_page:
    push_ay
    push tmp+0
    push tmp+1
    push tmp+2
    push tmp+3

    @in = tmp+0
    @out = tmp+2

    STX @in+1
    STY @out+1
    LDY #$00
    STY @in+0
    STY @out+0
    @loop:
        LDA (@in), Y
        STA (@out), Y
    to_y_inc @loop, #0

    pull tmp+3
    pull tmp+2
    pull tmp+1
    pull tmp+0
    pull_ay
    RTS

MAIN:

    .include "main/init.asm"

    @main_loop:
    JSR wait_next_frame

    .include "main/input.asm"
    .include "main/effect.asm"

    ; if we are not drawing the background
    LDA effect_flags
    AND #EFFECT_FLAG_DRAW
    bnz :+
        JSR update_screen_scroll
    :
    ; update graphics
    LDA txt_flags
    AND #(TXT_FLAG_BOX + TXT_FLAG_LZ + TXT_FLAG_PRINT)
    BNE :+
        JSR frame_decode
    :

    ; lz decode if needed
    LDA txt_flags
    AND #TXT_FLAG_LZ
    BEQ @lz_end
        JSR lz_decode
        and_adr txt_flags, #($FF-TXT_FLAG_LZ)
    @lz_end:

    ; draw/refresh dialog box if needed
    LDA txt_flags
    AND #TXT_FLAG_BOX
    BEQ @box_end
        ; if BOX_FLAG_REFRESH
        LDA box_flags
        AND #BOX_FLAG_REFRESH
        BEQ @box_redraw
        @box_refresh:
            ; then refresh dialog box
            JSR draw_dialog_box
            ; break
            JMP @box_done
        @box_redraw:
            ; else redraw dialog box by:
            ; - redrawing the bottom image in nametable 1
            LDA #>(PPU_NAMETABLE_1+$200)
            JSR img_draw_bot_lo
            JSR img_draw_bot_hi
            ; - push the midframe split & nametable flags
            push effect_flags
            ; clear the midframe split flag
            AND #($FF-EFFECT_FLAG_PAL_SPLIT)
            ; - set nametable 1 to be displayed
            ORA #EFFECT_FLAG_NT
            STA effect_flags
            ; - if dialog box is switching to on
            LDA box_flags
            AND #BOX_FLAG_HIDE
            BNE @box_redraw_hide
            @box_redraw_display:
                ; - then draw it
                JSR draw_dialog_box
                ; break
                JMP @box_redraw_end
            @box_redraw_hide:
                ; - else undraw it (by drawing the bottom image on top)
                LDA #>(PPU_NAMETABLE_0+$200)
                JSR img_draw_bot_lo
                JSR img_draw_bot_hi
            @box_redraw_end:
            ; - clear the midframe split & nametable flags
            and_adr effect_flags, #($FF-EFFECT_FLAG_PAL_SPLIT-EFFECT_FLAG_NT)
            ; - pull the midframe split & nametable flags
            PLA
            AND #(EFFECT_FLAG_PAL_SPLIT+EFFECT_FLAG_NT)
            ; flip the midframe split flag
            EOR #EFFECT_FLAG_PAL_SPLIT
            ORA effect_flags
            STA effect_flags
        @box_done:
        ; clear TXT_FLAG_BOX
        and_adr txt_flags, #($FF-TXT_FLAG_BOX)
    @box_end:

    ; loop back to start of main
    JMP @main_loop
