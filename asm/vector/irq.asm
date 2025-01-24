;################
; File: IRQ
;################


;--------------------------------
; Subroutine: IRQ
;--------------------------------
; IRQ vector
;
; IRQ can be trigger by APU or
; MMC5 scanline counter
;
; See Also: <scanline_irq_handler>
;--------------------------------
IRQ:
    ; clear APU interrupt
    BIT APU_STATUS
    ; clear scanline IRQ
    BIT MMC5_SCNL_STAT
    ; jump to scanline irq handler
    ; no matter the interrupt.
    ; This work because there is only
    ; the MMC5 scanline interrupt active.
    ; Plus, it fix a bug when
    ; DPCM hardware clean the MMC5 interrupt (why?)
    ; when fetching data right when the interrupt occure
    JMP scanline_irq_handler

    @end:
    ; return
    RTI
