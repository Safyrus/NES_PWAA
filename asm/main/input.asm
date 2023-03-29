    ; update player inputs
    JSR update_input

    ; update choice index
    LDA max_choice
    bze @no_choice
    @a_choice:
        ; is button A-B pressed ?
        LDA buttons_1
        TAX
        AND #$C0
        bnz @choice_validate
        ; is button R-D pressed ?
        TXA
        AND #$05
        bnz @choice_plus
        ; is button L-U pressed ?
        TXA
        AND #$0A
        bnz @choice_minus
        ; no button pressed
        JMP @flags_end

        @choice_plus:
            LDX choice
            INX
            CPX max_choice
            blt @choice_plus_update
                LDX #$00
            @choice_plus_update:
            STX choice
            JMP @flags_end
        @choice_minus:
            LDX choice
            DEX
            BPL @choice_minus_update
                LDX max_choice
                DEX
            @choice_minus_update:
            STX choice
            JMP @flags_end
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
            JMP @flags_end
    @no_choice:
        and_adr txt_flags, #($FF - TXT_FLAG_INPUT)
        ; is button A or B pressed ?
        LDA buttons_1
        AND #$C0
        BEQ @txt_input_next_end
            ora_adr txt_flags, #TXT_FLAG_INPUT
        @txt_input_next_end:
        ; is button B pressed ?
        LDA buttons_1
        AND #$40
        BEQ @txt_input_skip_end
            ora_adr txt_flags, #TXT_FLAG_SKIP
        @txt_input_skip_end:
    @flags_end:
