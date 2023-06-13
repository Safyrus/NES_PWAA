; case FAD
FAD:
    ; set fade timer
    mov fade_timer, #FADE_TIME
    ; if fade in flag set
    LDA effect_flags
    AND #EFFECT_FLAG_FADE
    BEQ @FAD_in
    @FAD_out:
        ; set fade out flag
        and_adr effect_flags, #($FF - EFFECT_FLAG_FADE)
        ; return
        RTS
    @FAD_in:
        ; set fade in flag
        ora_adr effect_flags, #EFFECT_FLAG_FADE
        ; return
        RTS
