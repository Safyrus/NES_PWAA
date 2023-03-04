; case TD
@TD:
    ; toggle flag to display dialog box
    eor_adr effect_flags, #EFFECT_FLAG_HIDE
    ;
    AND #EFFECT_FLAG_HIDE
    bze @td_on
    @td_off:
        JSR frame_decode
        ; set text bank
        mov MMC5_RAM_BNK, #TEXT_BUF_BNK
        RTS
    @td_on:
        JMP draw_dialog_box
