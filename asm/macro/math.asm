;################
; File: Macro - Math
;################

;--------------------------------
; Macro: inc_16
;--------------------------------
; increment a 16 bit value
;
; Param:
; adr - the address pointing to the value
;--------------------------------
.macro inc_16 adr
    .local @end
    ; increase pointer
    INC adr+0
    BNE @end
        INC adr+1
    @end:
.endmacro

;--------------------------------
; Macro: inc_16
;--------------------------------
; decrement a 16 bit value
;
; /!\ Warning /!\:
; - Change A to 0
;
; Param:
; adr - the address pointing to the value
;--------------------------------
.macro dec_16 adr
    .local @end
    ; decrease pointer
    LDA #$00
    CMP adr+0
    BNE @end
        DEC adr+1
    @end:
    DEC adr+0
.endmacro

;--------------------------------
; Macro: add_A2ptr
;--------------------------------
; Add the A register to a 16 bit pointer
;
; /!\ Warning /!\:
; - Change A
;
; Param:
; ptr - the address pointing to the value
; val - The value to load to A (optionnal)
;--------------------------------
.macro add_A2ptr ptr, val
    .local @end
    ; add A to pointer
.ifnblank val
    LDA val
.endif
    CLC
    ADC ptr+0
    STA ptr+0
    BCC @end
        INC ptr+1
    @end:
.endmacro
