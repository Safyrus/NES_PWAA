;**********
; Macros
;**********

.macro pushreg
    PHA
    TXA
    PHA
    TYA
    PHA
.endmacro


.macro pullreg
    PLA
    TAY
    PLA
    TAX
    PLA
.endmacro
