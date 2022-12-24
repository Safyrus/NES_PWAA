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

    @scanline_irq_bot:
        ; set next interrupt to scanline 1
        LDA #1
        STA MMC5_SCNL_VAL
        JMP @end

    @scanline_irq_top:
        ; set next interrupt to scanline 239
        LDA #239
        STA MMC5_SCNL_VAL
        JMP @end

    @end:
    PLA
    TAX
    PLA
    RTI

    @jump_lo:
        .byte <(@scanline_irq_bot-1)
        .byte <(@scanline_irq_top-1)
    @jump_hi:
        .byte >(@scanline_irq_bot-1)
        .byte >(@scanline_irq_top-1)
    @next:
        .byte SCANLINE_BOT
        .byte SCANLINE_TOP
