;################
; File: Macro - Stack
;################


;--------------------------------
; Macro: pushregs
;--------------------------------
; push all registers (A,X,Y)
;--------------------------------
.macro pushregs
    ; push A,X,Y
    PHA
    TXA
    PHA
    TYA
    PHA
.endmacro


;--------------------------------
; Macro: pullregs
;--------------------------------
; pull all registers (A,X,Y)
;--------------------------------
.macro pullregs
    ; pull A,X,Y
    PLA
    TAY
    PLA
    TAX
    PLA
.endmacro



;--------------------------------
; Macro: push_ax
;--------------------------------
; push A and X registers
;--------------------------------
.macro push_ax
    ; push A,X
    PHA
    TXA
    PHA
.endmacro


;--------------------------------
; Macro: pull_ax
;--------------------------------
; pull A and X registers
;--------------------------------
.macro pull_ax
    ; pull A,X
    PLA
    TAX
    PLA
.endmacro


;--------------------------------
; Macro: push_ay
;--------------------------------
; push A and Y registers
;--------------------------------
.macro push_ay
    ; push A,Y
    PHA
    TYA
    PHA
.endmacro


;--------------------------------
; Macro: pull_ay
;--------------------------------
; pull A and Y registers
;--------------------------------
.macro pull_ay
    ; pull A,Y
    PLA
    TAY
    PLA
.endmacro


;--------------------------------
; Macro: push
;--------------------------------
; push a value
;
; Param:
; adr - address to get the value to push
;--------------------------------
.macro push adr
    ; push val
    LDA adr
    PHA
.endmacro



;--------------------------------
; Macro: pull
;--------------------------------
; pull a value
;
; Param:
; adr - address where to store the value pulled
;--------------------------------
.macro pull adr
    ; pull val
    PLA
    STA adr
.endmacro
