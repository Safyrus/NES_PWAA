;----------
; math
;----------

.macro inc_16 adr
    .local @end
    ; increase pointer
    INC adr+0
    BNE @end
        INC adr+1
    @end:
.endmacro

; /!\ Change A to 0
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

; /!\ Change A
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
