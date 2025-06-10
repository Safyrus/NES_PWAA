dialog_reset:
    ; print_offset = DEFAULT_PRINT_OFFSET
    mov print_offset, #DEFAULT_PRINT_OFFSET
    ; print_start = print_offset
    STA print_start
    ; text_lb_offset = TWO_LINE_OFFSET_2_SPACE
    mov text_lb_offset, #TWO_LINE_OFFSET_2_SPACE
    ; put text adr to dialog stack
    LDX dialog_stack_ptr
    LDA txt_ptr+0
    STA dialog_stack_lo, X
    LDA txt_ptr+1
    STA dialog_stack_hi, X
    LDA lz_idx
    STA dialog_stack_bnk, X
    ; disable hold_it
    and_adr cr_flag, #($FF-CR_FLAG_HOLD)
    ; clear dialog box
    ; return
    JMP clear_dialog
