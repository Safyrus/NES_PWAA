EVT_SA:
    ; A = read_char()
    JSR read_char
    PHA
    ; scroll_spd = A & %1111100 >> 2
    AND #%1111100
    LSR
    LSR
    STA scroll_spd
    ; scroll_dir = A %0000011
    PLA
    AND #%0000011
    STA scroll_dir
    ; scroll_state = SCROLL_STATE_START
    LDA #SCROLL_STATE_START
    STA scroll_state
    ; return
    RTS
