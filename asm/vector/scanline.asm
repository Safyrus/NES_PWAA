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

    @scanline_irq_dialog:
        .include "scanline_pal_change.asm"

    @scanline_irq_top:
        ; nametable mapping change done at the end of NMI
        ; (because we are too late at scanline 1 and we can't interrupt before without eating NMI time)
        LDA #NT_MAPPING_EMPTY
        STA MMC5_NAMETABLE
        ; change sprite to 8*16
        LDA ppu_ctrl_val
        ORA #PPU_CTRL_SPR_SIZE
        STA ppu_ctrl_val
        STA PPU_CTRL
        ; update CHR banks & CHR upper bits for every frame
        ; in frame before any potential palette split
        ; (reason still unknow why this fix a bug where
        ;  CHR bank are from region 0 (due to palette split changing it to 0)
        ;  but not BKG tiles for a noticable number of frames)
        mov MMC5_CHR_UPPER, mmc5_upper_chr
        mov MMC5_CHR_BNK0, cur_bnks+0
        mov MMC5_CHR_BNK1, cur_bnks+1
        mov MMC5_CHR_BNK2, cur_bnks+2
        mov MMC5_CHR_BNK3, cur_bnks+3
        mov MMC5_CHR_BNK4, cur_bnks+4
        mov MMC5_CHR_BNK5, cur_bnks+5
        mov MMC5_CHR_BNK6, cur_bnks+6
        mov MMC5_CHR_BNK7, cur_bnks+7
        ; return
        JMP @end
    @scanline_irq_top_img:
        ;
        LDA mmc5_upper_chr
        STA MMC5_CHR_UPPER
        ; change nametable mapping
        LDA #NT_MAPPING_NT12
        STA MMC5_NAMETABLE
        ; return
        JMP @end
    @scanline_irq_top_midbox:
        ; if the court record or choice is showned
        LDA act_nchoice
        BNE @scanline_irq_top_midbox_change
        LDA cr_flag
        AND #CR_FLAG_OPEN
        BEQ @scanline_irq_top_midbox_end
        @scanline_irq_top_midbox_change:
            ; scroll to the top left nametable
            LDA ppu_ctrl_val
            AND #$FC
            STA PPU_CTRL
            ; set mmc5 high upper chr bits to 0
            LDA #$00
            STA MMC5_CHR_UPPER
        @scanline_irq_top_midbox_end:
        ; return
        JMP @end
    @scanline_irq_bot_midbox:
        ; if the court record or choice is showned
        LDA act_nchoice
        BNE @scanline_irq_bot_midbox_change
        LDA cr_flag
        AND #CR_FLAG_OPEN
        BEQ @scanline_irq_bot_midbox_end
        @scanline_irq_bot_midbox_change:
            ; restore scroll
            LDA ppu_ctrl_val
            STA PPU_CTRL
            ; restore chr upper bit
            LDA mmc5_upper_chr
            STA MMC5_CHR_UPPER
        @scanline_irq_bot_midbox_end:
        ; return
        JMP @end
    @scanline_irq_name:
        ; if name is displayed
        LDA text_name
        BMI :+
            ; change sprite to 8*8
            LDA ppu_ctrl_val
            AND #$FF-PPU_CTRL_SPR_SIZE
            STA ppu_ctrl_val
            STA PPU_CTRL
        :
        ; return
        JMP @end
    @scanline_irq_bot_img:
        ; change nametable mapping
        LDA #NT_MAPPING_EMPTY
        STA MMC5_NAMETABLE
        ; enable sprite rendering if disable
        LDA #(PPU_MASK_BKG + PPU_MASK_BKG8 + PPU_MASK_SPR + PPU_MASK_SPR8)
        STA PPU_MASK
        ;
        BIT effect_flags
        BPL @botimg_next
            @botimg_palette_change:
            ; override next scanline.
            ; Because we have disabled rendering,
            ; MMC5 scanline counter is now at 0 at this scanline (where we re-enabled rendering).
            ; But it seems that doing this strategy only work well one time per frame, becoming unreliable after that.
            ; This seems to make the MMC5 scanline counter wait for the next frame to take effect.
            ; Therefore, we will jump a the start of next frame
            LDA #1
            STA MMC5_SCNL_VAL
        @botimg_next:
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
        .byte <(@scanline_irq_name-1)
        .byte <(@scanline_irq_dialog-1)
        .byte <(@scanline_irq_bot_img-1)
        .byte <(@scanline_irq_top-1)
    @jump_hi:
        .byte >(@scanline_irq_top_img-1)
        .byte >(@scanline_irq_top_midbox-1)
        .byte >(@scanline_irq_bot_midbox-1)
        .byte >(@scanline_irq_name-1)
        .byte >(@scanline_irq_dialog-1)
        .byte >(@scanline_irq_bot_img-1)
        .byte >(@scanline_irq_top-1)
    @next_state:
        .byte SCANLINE_TOP_IMG
        .byte SCANLINE_TOP_MIDBOX
        .byte SCANLINE_BOT_MIDBOX
        .byte SCANLINE_NAME
        .byte SCANLINE_DIALOG
        .byte SCANLINE_BOT_IMG
        .byte SCANLINE_TOP
    @next_line:
        .byte 54
        .byte 118
        .byte 142
        .byte 151
        .byte 215 ; not used
        .byte 1
        .byte 23
