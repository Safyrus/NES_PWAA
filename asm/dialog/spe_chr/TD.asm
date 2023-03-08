; case TD
@TD:
    ; toggle flag to display dialog box
    eor_adr effect_flags, #EFFECT_FLAG_HIDE
    ;
    AND #EFFECT_FLAG_HIDE
    bze @td_on
    @td_off:
        JMP find_anim
    @td_on:
        ora_adr txt_flags, #TXT_FLAG_BOX
        RTS
