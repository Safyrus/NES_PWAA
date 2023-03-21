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
    PLA
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

    ; draw dialog box if needed
    LDA txt_flags
    AND #TXT_FLAG_BOX
    BEQ @box_end
        JSR draw_dialog_box
        and_adr txt_flags, #($FF-TXT_FLAG_BOX)
    @box_end:

    ; loop back to start of main
    JMP @main_loop
