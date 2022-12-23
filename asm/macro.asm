;**********
; Macros
;**********

.macro pushregs
    PHA
    TXA
    PHA
    TYA
    PHA
.endmacro


.macro pullregs
    PLA
    TAY
    PLA
    TAX
    PLA
.endmacro
