EVT_CRH:
    ; enable hold_it
    ora_adr cr_flag, #CR_FLAG_HOLD
    ; increase dialog_stack
    LDX dialog_stack_ptr
    INX
    CPX #DIALOG_STACK_SIZE
    BNE :+
        LDX #$00
    :
    STX dialog_stack_ptr
    ; cr_hold_jmp = read_jump()
    JSR read_jump
    mov cr_hold_jmp+0, jmp_buf+0
    mov cr_hold_jmp+1, jmp_buf+1
    mov cr_hold_jmp+2, jmp_buf+2
    ; return
    RTS
