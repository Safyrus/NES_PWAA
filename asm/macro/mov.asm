;################
; File: Macro - Move
;################


;--------------------------------
; Macro: mov
;--------------------------------
; Move the src to the dst using the A register
;
; Params:
; dst - Destination address
; src - Source
;--------------------------------
.macro mov dst, src
    ; mov A
    LDA src
    STA dst
.endmacro


;--------------------------------
; Macro: mvx
;--------------------------------
; Move the src to the dst using the X register
;
; Params:
; dst - Destination address
; src - Source
;--------------------------------
.macro mvx dst, src
    ; mov X
    LDX src
    STX dst
.endmacro


;--------------------------------
; Macro: mvy
;--------------------------------
; Move the src to the dst using the Y register
;
; Params:
; dst - Destination address
; src - Source
;--------------------------------
.macro mvy dst, src
    ; mov Y
    LDY src
    STY dst
.endmacro


;--------------------------------
; Macro: sta_ptr
;--------------------------------
; Store a value to a pointer using the A register
;
; Params:
; dst - Destination address
; src - Pointer value
;--------------------------------
.macro sta_ptr dst, val
    ; store pointer
    LDA #<val
    STA dst+0
    LDA #>val
    STA dst+1
.endmacro


;--------------------------------
; Macro: stx_ptr
;--------------------------------
; Store a value to a pointer using the X register
;
; Params:
; dst - Destination address
; src - Pointer value
;--------------------------------
.macro stx_ptr dst, val
    ; store pointer
    LDX #<val
    STX dst+0
    LDX #>val
    STX dst+1
.endmacro


;--------------------------------
; Macro: sty_ptr
;--------------------------------
; Store a value to a pointer using the Y register
;
; Params:
; dst - Destination address
; src - Pointer value
;--------------------------------
.macro sty_ptr dst, val
    ; store pointer
    LDY #<val
    STY dst+0
    LDY #>val
    STY dst+1
.endmacro


;--------------------------------
; Macro: mov_ptr
;--------------------------------
; move a value from a pointer to another
; using the A register
;
; Params:
; dst - Destination address
; src - Source address
;--------------------------------
.macro mov_ptr dst, src
    mov dst+0, src+0
    mov dst+1, src+1
.endmacro


;--------------------------------
; Macro: mvx_ptr
;--------------------------------
; move a value from a pointer to another
; using the X register
;
; Params:
; dst - Destination address
; src - Source address
;--------------------------------
.macro mvx_ptr dst, src
    mvx dst+0, src+0
    mvx dst+1, src+1
.endmacro


;--------------------------------
; Macro: mvy_ptr
;--------------------------------
; move a value from a pointer to another
; using the Y register
;
; Params:
; dst - Destination address
; src - Source address
;--------------------------------
.macro mvy_ptr dst, src
    mvy dst+0, src+0
    mvy dst+1, src+1
.endmacro

