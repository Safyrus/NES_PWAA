    ; if this dialog is a choice
    LDA max_choice
    bze @choice_end
    @a_choice:
        ; is button A-B pressed ?
        LDA buttons_1
        TAX
        AND #(BTN_A+BTN_B)
        bnz @choice_validate
        ; is button R-D pressed ?
        TXA
        AND #(BTN_DOWN+BTN_RIGHT)
        bnz @choice_plus
        ; is button L-U pressed ?
        TXA
        AND #(BTN_UP+BTN_LEFT)
        bnz @choice_minus
        ; no button pressed
        JMP @input_end

        @choice_plus:
            LDX choice
            INX
            CPX max_choice
            blt @choice_plus_update
                LDX #$00
            @choice_plus_update:
            STX choice
            JMP @input_end
        @choice_minus:
            LDX choice
            DEX
            BPL @choice_minus_update
                LDX max_choice
                DEX
            @choice_minus_update:
            STX choice
            JMP @input_end
        @choice_validate:
            ; get choice_jmp_table index
            mov MMC5_MUL_A, choice
            mov MMC5_MUL_B, #$03
            LDX MMC5_MUL_A
            ; copy choice_jmp_table to jump buf
            LDA choice_jmp_table, X
            STA txt_jump_buf+0
            INX
            LDA choice_jmp_table, X
            STA txt_jump_buf+1
            INX
            LDA choice_jmp_table, X
            STA txt_jump_buf+2
            ; jump to that address
            JSR read_jump
            ;
            LDA #$00
            STA max_choice
            STA choice
            JMP @input_end
    @choice_end:
