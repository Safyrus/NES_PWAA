;----------
; mov
;----------

.macro mov dst, src
    ; mov A
    LDA src
    STA dst
.endmacro

.macro mvx dst, src
    ; mov X
    LDX src
    STX dst
.endmacro

.macro mvy dst, src
    ; mov Y
    LDY src
    STY dst
.endmacro

.macro sta_ptr dst, val
    ; store pointer
    LDA #<val
    STA dst+0
    LDA #>val
    STA dst+1
.endmacro

.macro stx_ptr dst, val
    ; store pointer
    LDX #<val
    STX dst+0
    LDX #>val
    STX dst+1
.endmacro

.macro sty_ptr dst, val
    ; store pointer
    LDY #<val
    STY dst+0
    LDY #>val
    STY dst+1
.endmacro

.macro mov_ptr dst, src
    mov dst+0, src+0
    mov dst+1, src+1
.endmacro

.macro mvx_ptr dst, src
    mvx dst+0, src+0
    mvx dst+1, src+1
.endmacro

.macro mvy_ptr dst, src
    mvy dst+0, src+0
    mvy dst+1, src+1
.endmacro

