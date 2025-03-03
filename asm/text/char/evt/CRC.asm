EVT_CRC:
    ; clear_evidence_flag(read_char())
    JSR read_char
    JSR clear_evidence_flag
    ; return
    RTS
