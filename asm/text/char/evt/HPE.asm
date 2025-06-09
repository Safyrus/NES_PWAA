EVT_HPE:
    ; c = read_char()
    JSR read_char
    ; hp_evt_n = c & %00000111
    ; hp_evt_t = (c & %00011000) >> 3
    STA hp_evt_n
    LDA hp_evt_n
    AND #%00011000
    LSR
    LSR
    LSR
    STA hp_evt_t
    LDA hp_evt_n
    AND #%00000111
    STA hp_evt_n
    ; hp_jmp = read_jump()
    JSR read_jump
    mov hp_jmp+0, jmp_buf+0
    mov hp_jmp+1, jmp_buf+1
    mov hp_jmp+2, jmp_buf+2
    ; return
    RTS
