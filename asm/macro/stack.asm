;----------
; stack
;----------

.macro pushregs
    ; push A,X,Y
    PHA
    TXA
    PHA
    TYA
    PHA
.endmacro

.macro pullregs
    ; pull A,X,Y
    PLA
    TAY
    PLA
    TAX
    PLA
.endmacro

.macro push_ax
    ; push A,X
    PHA
    TXA
    PHA
.endmacro

.macro pull_ax
    ; pull A,X
    PLA
    TAX
    PLA
.endmacro

.macro push_ay
    ; push A,Y
    PHA
    TYA
    PHA
.endmacro

.macro pull_ay
    ; pull A,Y
    PLA
    TAY
    PLA
.endmacro

.macro push adr
    ; push val
    LDA adr
    PHA
.endmacro

.macro pull adr
    ; pull val
    PLA
    STA adr
.endmacro
