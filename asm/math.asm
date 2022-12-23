.macro inc_16 adr
    .local @end
    INC adr+0
    BNE @end
        INC adr+1
    @end:
.endmacro

; /!\ Change A
.macro add_A2ptr ptr
    .local @end
    CLC
    ADC ptr+0
    STA ptr+0
    BCC @end
        INC ptr+1
    @end:
.endmacro
