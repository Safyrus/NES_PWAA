NAM:
    ; name = read_char()
    JSR read_char
    ; if name == text_name (same as last)
    CMP text_name
    BNE :+
        ; name = none
        LDA #$FF
    :
    ; text_name = name
    STA text_name
    ; change_name()
    ; return
    JMP change_name
