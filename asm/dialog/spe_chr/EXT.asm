; case EXT
EXT:
    ; e = next_char()
    JSR read_next_char
    ; extension_char(e)
    ; JMP exec_ext
    RTS
