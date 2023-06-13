; case ACT
ACT:
    @ACT_while:
        ; read next jump adr
        JSR read_next_jmp
        BMI @ACT_end ; return if async lz() has been called

        ; if condition flag is present
        BIT txt_jump_flag_buf
        BVC @ACT_cond_end
            ; c_idx = next_char()
            JSR read_next_char
            BMI @ACT_end ; return if async lz() has been called
            ; flag = dialog_flags[c_idx]
            JSR get_dialog_flag
            ; if flag clear then skip this choice
            BEQ @ACT_while_next
        @ACT_cond_end:

        ; get choice_jmp_table index
        mov MMC5_MUL_A, max_choice
        mov MMC5_MUL_B, #$03
        LDX MMC5_MUL_A
        ; copy jump adr to choice_jmp_table
        LDA txt_jump_buf+0
        STA choice_jmp_table, X
        INX
        LDA txt_jump_buf+1
        STA choice_jmp_table, X
        INX
        LDA txt_jump_buf+2
        STA choice_jmp_table, X
        ; increase the number of choice
        INC max_choice

        ; read choice text
        @ACT_while_read:
            JSR read_next_char
            BMI @ACT_end ; return if async lz() has been called
            JSR print_char
            CMP #$01
            BNE @ACT_while_read
        JSR print_lb
        ; while end
        @ACT_while_next:
        BIT txt_jump_flag_buf
        BMI @ACT_while
    
    LDX background_index
    LDA max_choice
    ASL
    ORA #$80
    STA background, X
    INX
    LDA #>($2281)
    STA background, X
    INX
    LDA #<($2281)
    STA background, X
    INX
    LDY max_choice
    @ACT_draw:
        LDA #$3E
        STA background, X
        INX
        LDA #BOX_TILE_M
        STA background, X
        INX
        DEY
        bnz @ACT_draw
    LDA #$00
    STA background, X
    STX background_index
    @ACT_end:
    RTS
