;----------
; loop
;----------
.macro for_x label, init
    ; for x
    LDX init
    label:
.endmacro

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

.macro for_y label, init
    ; for y
    LDY init
    label:
.endmacro

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
