EVT_CRS:
    ; set_evidence_flag(read_char())
    JSR read_char
    JSR set_evidence_flag
    ; return
    RTS
