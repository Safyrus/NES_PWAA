;***********
; IRQ vector
;***********


IRQ:
    ; clear scanline IRQ
    BIT MMC5_SCNL_STAT
    BPL @scanline_irq_end
        JMP scanline_irq_handler
    @scanline_irq_end:

    ; clear APU interrupt
    BIT APU_STATUS
    BVC @apu_irq_end
        JMP @end
    @apu_irq_end:

    @end:
    ; return
    RTI
