TD:
    ; flush text
    JSR flush
    ;
    LDA effect_flags
    ORA #EFFECT_FLAG_DB_ANIM
    EOR #EFFECT_FLAG_DIALOG
    STA effect_flags
    ;
    LDA txt_flags
    ORA #$01
    STA txt_flags
    ; return
    RTS
