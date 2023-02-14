; case TD
@TD:
    ; toggle flag to display dialog box
    LDA effect_flags
    EOR #EFFECT_FLAG_HIDE
    STA effect_flags
    ;
    AND #EFFECT_FLAG_HIDE
    BEQ @td_on
    @td_off:
        JSR frame_decode
        ; set text bank
        LDA #TEXT_BUF_BNK
        STA MMC5_RAM_BNK
        RTS
    @td_on:
        JSR draw_dialog_box
        RTS
