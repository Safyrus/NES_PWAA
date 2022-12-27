scanline_irq_handler:
    ; push x
    TXA
    PHA

    ; jump to function
    LDA scanline
    AND #$3F
    TAX
    LDA @jump_hi, X
    PHA
    LDA @jump_lo, X
    PHA
    ; but just before that, set the new scanline state
    LDA @next, X
    STA scanline
    RTS

    @scanline_irq_top:
        ; set next interrupt to scanline 24
        LDA #24
        STA MMC5_SCNL_VAL
        ; nametable mapping change done at the end of NMI
        ; (because we are too late at scanline 1 and we can't interrupt before without eating NMI time)
        LDA #NT_MAPPING_EMPTY
        STA MMC5_NAMETABLE
        ; return
        JMP @end
    @scanline_irq_top_img:
        ; set next interrupt to scanline 216
        LDA #216
        STA MMC5_SCNL_VAL
        ; change nametable mapping
        LDA #NT_MAPPING_NT1
        STA MMC5_NAMETABLE
        ; return
        JMP @end
    @scanline_irq_bot_img:
        ; set next interrupt to scanline 239
        LDA #239
        STA MMC5_SCNL_VAL
        ; change nametable mapping
        LDA #NT_MAPPING_EMPTY
        STA MMC5_NAMETABLE
        ; return
        JMP @end
    @scanline_irq_bot:
        ; set next interrupt to scanline 1
        LDA #1
        STA MMC5_SCNL_VAL
        ; change nametable mapping
        LDA #NT_MAPPING_NT1
        STA MMC5_NAMETABLE
        ; return
        JMP @end

    @end:
    PLA
    TAX
    PLA
    RTI

    @jump_lo:
        .byte <(@scanline_irq_top_img-1)
        .byte <(@scanline_irq_bot_img-1)
        .byte <(@scanline_irq_bot-1)
        .byte <(@scanline_irq_top-1)
    @jump_hi:
        .byte >(@scanline_irq_top_img-1)
        .byte >(@scanline_irq_bot_img-1)
        .byte >(@scanline_irq_bot-1)
        .byte >(@scanline_irq_top-1)
    @next:
        .byte SCANLINE_TOP_IMG
        .byte SCANLINE_BOT_IMG
        .byte SCANLINE_BOT
        .byte SCANLINE_TOP
