EVT:
    ; c = read_char()
    JSR read_char
    TAX
    ; - - - - - - - -
    ; switch (c)
    ; - - - - - - - -
    ; push return adr
    LDA #>(@ret-1)
    PHA
    LDA #<(@ret-1)
    PHA
    ; push jump adr
    LDA @switch_evt_hi, X
    PHA
    LDA @switch_evt_lo, X
    PHA
    ; jump
    @ret:
    RTS

    @switch_evt_lo:
        .byte <(EVT_CR-1)   ; $00
        .byte <(EVT_CRF-1)  ; $01
        .byte <(EVT_CRO-1)  ; $02
        .byte <(EVT_CRH-1)  ; $03
        .byte <(EVT_CRS-1)  ; $04
        .byte <(EVT_CRC-1)  ; $05
        .byte <(EVT_CRI-1)  ; $06
        .byte <(EVT_CRN-1)  ; $07
        .byte <(EVT_HPT-1)  ; $08
        .byte <(EVT_HPE-1)  ; $09
        .byte <(EVT_HPS-1)  ; $0A
        .byte <(EVT_HPA-1)  ; $0B
        .byte <(EVT_SL1-1)  ; $0C
        .byte <(EVT_SL2-1)  ; $0D
        .byte <(EVT_SA-1)   ; $0E
        .byte <(EVT_EXA-1)  ; $0F
    @switch_evt_hi:
        .byte >(EVT_CR-1)   ; $00
        .byte >(EVT_CRF-1)  ; $01
        .byte >(EVT_CRO-1)  ; $02
        .byte >(EVT_CRH-1)  ; $03
        .byte >(EVT_CRS-1)  ; $04
        .byte >(EVT_CRC-1)  ; $05
        .byte >(EVT_CRI-1)  ; $06
        .byte >(EVT_CRN-1)  ; $07
        .byte >(EVT_HPT-1)  ; $08
        .byte >(EVT_HPE-1)  ; $09
        .byte >(EVT_HPS-1)  ; $0A
        .byte >(EVT_HPA-1)  ; $0B
        .byte >(EVT_SL1-1)  ; $0C
        .byte >(EVT_SL2-1)  ; $0D
        .byte >(EVT_SA-1)   ; $0E
        .byte >(EVT_EXA-1)  ; $0F
