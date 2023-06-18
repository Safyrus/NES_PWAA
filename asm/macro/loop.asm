;################
; File: Macro - loop
;################

;--------------------------------
; Macro: for_x
;--------------------------------
; Starting macro to write a for loop
; using the X register
;
; Params:
; label - Starting label of the loop
; init  - The initial value to set the register at
;--------------------------------
.macro for_x label, init
    ; for x
    LDX init
    label:
.endmacro


;--------------------------------
; Macro: to_x_dec
;--------------------------------
; Ending macro to write a for loop
; using the X register
;
; This will make X decrement each time when
; it reach the end of the loop
;
; Params:
; label - Label pointing to the start of the loop
; val  - The value to end the loop (if X == val)
;--------------------------------
.macro to_x_dec label, val
    ; end for x (dec)
    DEX
.if .xmatch ({val}, #0)
    BNE label
.elseif .xmatch ({val}, #-1)
    BPL label
.else
    CPX val
    BNE label
.endif
.endmacro


;--------------------------------
; Macro: to_x_inc
;--------------------------------
; Ending macro to write a for loop
; using the X register
;
; This will make X increment each time when
; it reach the end of the loop
;
; Params:
; label - Label pointing to the start of the loop
; val  - The value to end the loop (if X == val)
;--------------------------------
.macro to_x_inc label, val
    ; end for x (inc)
    INX
.if .xmatch ({val}, #0)
    BNE label
.elseif .xmatch ({val}, #-1)
    BPL label
.else
    CPX val
    BNE label
.endif
.endmacro


;--------------------------------
; Macro: for_y
;--------------------------------
; Starting macro to write a for loop
; using the Y register
;
; Params:
; label - Starting label of the loop
; init  - The initial value to set the register at
;--------------------------------
.macro for_y label, init
    ; for y
    LDY init
    label:
.endmacro


;--------------------------------
; Macro: to_y_dec
;--------------------------------
; Ending macro to write a for loop
; using the Y register
;
; This will make Y decrement each time when
; it reach the end of the loop
;
; Params:
; label - Label pointing to the start of the loop
; val  - The value to end the loop (if Y == val)
;--------------------------------
.macro to_y_dec label, val
    ; end for y (dec)
    DEY
.if .xmatch ({val}, #0)
    BNE label
.elseif .xmatch ({val}, #-1)
    BPL label
.else
    CPY val
    BNE label
.endif
.endmacro

;--------------------------------
; Macro: to_y_dec
;--------------------------------
; Ending macro to write a for loop
; using the Y register
;
; This will make Y increment each time when
; it reach the end of the loop
;
; Params:
; label - Label pointing to the start of the loop
; val  - The value to end the loop (if Y == val)
;--------------------------------
.macro to_y_inc label, val
    ; end for y (inc)
    INY
.if .xmatch ({val}, #0)
    BNE label
.elseif .xmatch ({val}, #-1)
    BPL label
.else
    CPY val
    BNE label
.endif
.endmacro
