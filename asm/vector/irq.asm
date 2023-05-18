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

    PHA
    ; if DPCM byte remaining == 0
    LDA APU_STATUS
    AND #$10
    BNE @dpcm_end
        mov APU_DMC_FREQ, #$00 ; clear interrupt flag
        mov APU_SND_CHN, #%00001111 ; stop DPCM
    @dpcm_end:
    PLA

    @end:
    ; return
    RTI
