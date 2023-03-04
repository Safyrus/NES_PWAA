;----------
; boolean
;----------

.macro ora_adr adr, val
    ; or value at adr with val
    LDA adr
    ORA val
    STA adr
.endmacro

.macro and_adr adr, val
    ; and value at adr with val
    LDA adr
    AND val
    STA adr
.endmacro

.macro eor_adr adr, val
    ; xor value at adr with val
    LDA adr
    EOR val
    STA adr
.endmacro

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
