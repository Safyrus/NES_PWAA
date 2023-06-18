;################
; File: Macro - boolean
;################

;--------------------------------
; Macro: ora_adr
;--------------------------------
; update value at adr by ORing the content with val
;
; Params:
; adr - address to update
; val - value to OR with adr
;--------------------------------
.macro ora_adr adr, val
    ; or value at adr with val
    LDA adr
    ORA val
    STA adr
.endmacro

;--------------------------------
; Macro: and_adr
;--------------------------------
; update value at adr by ANDing the content with val
;
; Params:
; adr - address to update
; val - value to AND with adr
;--------------------------------
.macro and_adr adr, val
    ; and value at adr with val
    LDA adr
    AND val
    STA adr
.endmacro

;--------------------------------
; Macro: eor_adr
;--------------------------------
; update value at adr by XORing the content with val
;
; Params:
; adr - address to update
; val - value to XOR with adr
;--------------------------------
.macro eor_adr adr, val
    ; xor value at adr with val
    LDA adr
    EOR val
    STA adr
.endmacro

;--------------------------------
; Macro: shift
;--------------------------------
; Do n Shift.
; More precisely, Do the instruction ins n times.
;
; Params:
; ins - the shift instruction to use
; n - the number of time to shift
;--------------------------------
.macro shift ins, n
.if .xmatch ({n}, 1)
ins
.elseif .xmatch ({n}, 2)
ins
ins
.elseif .xmatch ({n}, 3)
ins
ins
ins
.elseif .xmatch ({n}, 4)
ins
ins
ins
ins
.elseif .xmatch ({n}, 5)
ins
ins
ins
ins
ins
.elseif .xmatch ({n}, 6)
ins
ins
ins
ins
ins
ins
.elseif .xmatch ({n}, 7)
ins
ins
ins
ins
ins
ins
ins
.else
.error "wrong parameters for shift macro"
.endif
.endmacro
