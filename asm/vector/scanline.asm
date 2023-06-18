;################
; File: Scanline
;################

;--------------------------------
; Subroutine: scanline_irq_handler
;--------------------------------
; Handler for MMC5 scanline IRQ
;--------------------------------
scanline_irq_handler:
    pushregs

    ; priority to palette change
    LDA scanline
    CMP #SCANLINE_DIALOG-1
    BEQ @scanline_irq_dialog

    ; prepare the jump
    LDA scanline
    AND #$3F
    TAX
    LDA @jump_hi, X
    PHA
    LDA @jump_lo, X
    PHA
    ; set the new scanline state
    LDA @next_state, X
    STA scanline
    ; set next scanline
    LDA @next_line, X
    STA MMC5_SCNL_VAL
    ; jump
    RTS

    @scanline_irq_top:
        ; nametable mapping change done at the end of NMI
        ; (because we are too late at scanline 1 and we can't interrupt before without eating NMI time)
        LDA #NT_MAPPING_EMPTY
        STA MMC5_NAMETABLE
        ; return
        JMP @end
    @scanline_irq_top_img:
        ;
        LDA mmc5_upper_chr
        STA MMC5_CHR_UPPER
        ; change nametable mapping
        LDA #NT_MAPPING_NT1
        STA MMC5_NAMETABLE
        ; return
        JMP @end
    @scanline_irq_top_midbox:
        ; if the court record is showned
        LDA cr_flag
        AND #CR_FLAG_SHOW
        BEQ @scanline_irq_top_midbox_end
            ; then disable sprites
            LDA #PPU_MASK_BKG+PPU_MASK_BKG8
            STA PPU_MASK
            ; and update scrolling
            LDA ppu_ctrl_val
            AND #$FC
            STA PPU_CTRL
            ; and update mmmc5 high upper chr bits
            LDA #$00
            STA mmc5_upper_chr
            ; and set chr upper bit to 0
            LDA #$00
            STA MMC5_CHR_UPPER
        @scanline_irq_top_midbox_end:
        ; return
        JMP @end
    @scanline_irq_bot_midbox:
        ; if the court record is showned
        LDA cr_flag
        AND #CR_FLAG_SHOW
        BEQ @scanline_irq_bot_midbox_end
            ; then enable sprites
            LDA #PPU_MASK_BKG+PPU_MASK_BKG8+PPU_MASK_SPR+PPU_MASK_SPR8
            STA PPU_MASK
            ; and update scrolling
            JSR update_screen_scroll
            ; and restore chr upper bit
            LDA mmc5_upper_chr
            STA MMC5_CHR_UPPER
        @scanline_irq_bot_midbox_end:
        ; return
        JMP @end
    @scanline_irq_dialog:
        .include "scanline_pal_change.asm"
    @scanline_irq_bot_img:
        ;
        BIT effect_flags
        BPL @botimg_next
            @botimg_palette_change:
            ; set next scanline.
            ; Because we have disabled rendering,
            ; MMC5 scanline counter is now at 0 at the scanline where we re-enabled rendering,
            ; Therefore, scanline 83 mean scanline when enable (155) + 83 = 238
            LDA #83
            STA MMC5_SCNL_VAL
        @botimg_next:
        ;
        LDA #(PPU_MASK_BKG + PPU_MASK_BKG8 + PPU_MASK_SPR + PPU_MASK_SPR8)
        STA PPU_MASK
        ;
        LDA #$00
        STA MMC5_CHR_UPPER
        ; change nametable mapping
        LDA #NT_MAPPING_EMPTY
        STA MMC5_NAMETABLE
        ; return
        JMP @end
    @scanline_irq_bot:
        ; change nametable mapping
        LDA #NT_MAPPING_NT1
        STA MMC5_NAMETABLE
        ; return
        JMP @end

    @end:
    pullregs
    ; return
    RTI

    @jump_lo:
        .byte <(@scanline_irq_top_img-1)
        .byte <(@scanline_irq_top_midbox-1)
        .byte <(@scanline_irq_bot_midbox-1)
        .byte <(@scanline_irq_dialog-1)
        .byte <(@scanline_irq_bot_img-1)
        .byte <(@scanline_irq_bot-1)
        .byte <(@scanline_irq_top-1)
    @jump_hi:
        .byte >(@scanline_irq_top_img-1)
        .byte >(@scanline_irq_top_midbox-1)
        .byte >(@scanline_irq_bot_midbox-1)
        .byte >(@scanline_irq_dialog-1)
        .byte >(@scanline_irq_bot_img-1)
        .byte >(@scanline_irq_bot-1)
        .byte >(@scanline_irq_top-1)
    @next_state:
        .byte SCANLINE_TOP_IMG
        .byte SCANLINE_TOP_MIDBOX
        .byte SCANLINE_BOT_MIDBOX
        .byte SCANLINE_DIALOG
        .byte SCANLINE_BOT_IMG
        .byte SCANLINE_BOT
        .byte SCANLINE_TOP
    @next_line:
        .byte 54
        .byte 118
        .byte 151
        .byte 215 ; not used
        .byte 238
        .byte 1
        .byte 23
