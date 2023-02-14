; case EVT
@EVT:
    ; e = next_char()
    JSR read_next_char
    ; jsr event_table[e]
    JMP exec_evt
