;***********
; IRQ vector
;***********


IRQ:
    ; save register
    PHA

    ; clear APU interrupt
    LDA APU_STATUS

    ; restore register
    PLA
    ; return
    RTI