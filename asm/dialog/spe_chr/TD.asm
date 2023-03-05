; case TD
@TD:
    ; toggle flag to display dialog box
    eor_adr effect_flags, #EFFECT_FLAG_HIDE
    ;
    AND #EFFECT_FLAG_HIDE
    bze @td_on
    @td_off:
        ; main normally refresh image every frame
        ; so we don't need to do it
        RTS
    @td_on:
        ora_adr txt_flags, #TXT_FLAG_BOX
        RTS
