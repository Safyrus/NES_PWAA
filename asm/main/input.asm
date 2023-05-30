    ; update player inputs
    JSR update_input

    ; update choice index
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

    ; if court record is displayed
    LDA cr_flag
    AND #CR_FLAG_SHOW
    BEQ @cr_end
    @cr:
        and_adr txt_flags, #($FF - TXT_FLAG_INPUT)
        ; is button SELECT pressed ?
        LDA buttons_1
        AND #BTN_SELECT
        BEQ @cr_select_end
            ; then set/clear court record show flag
            and_adr cr_flag, #($FF-CR_FLAG_SHOW)
            ; and draw/undraw the court record
            JSR update_court_record_box
        @cr_select_end:
        ; is button RIGHT pressed ?
        LDA buttons_1
        AND #BTN_RIGHT
        BEQ @cr_left_end
            ; increase evidence index
            INC evidence_idx
            ; if index > MAX_EVIDENCE_IDX
            LDA evidence_idx
            CMP #MAX_EVIDENCE_IDX
            blt @cr_left_update
                ; index = 0
                mov evidence_idx, #$00
            @cr_left_update:
            ; update the court record display
            JSR update_court_record_box
        @cr_left_end:
        ; is button LEFT pressed ?
        LDA buttons_1
        AND #BTN_LEFT
        BEQ @cr_right_end
            ; decrease evidence index
            DEC evidence_idx
            ; if index < 0
            BPL @cr_right_update
                ; index = MAX_EVIDENCE_IDX
                mov evidence_idx, #MAX_EVIDENCE_IDX
            @cr_right_update:
            ; update the court record display
            JSR update_court_record_box
        @cr_right_end:
        JMP @input_end
    @cr_end:

    @normal_input:
        and_adr txt_flags, #($FF - TXT_FLAG_INPUT)
        ; is button SELECT pressed ?
        LDA buttons_1
        AND #BTN_SELECT
        BEQ @txt_input_cr_end
            ; if the text is waiting for a player inpput
            LDA txt_flags
            AND #TXT_FLAG_WAIT
            BEQ @txt_input_cr_end
            ; and if the court record can be access
            ; LDA cr_flag
            ; AND #CR_FLAG_ACCESS
            ; BEQ @txt_input_cr_end
                ; then set/clear court record show flag
                ora_adr cr_flag, #CR_FLAG_SHOW
                ; and draw/undraw the court record
                JSR update_court_record_box
                JMP @input_end
        @txt_input_cr_end:
        ; is button A or B pressed ?
        LDA buttons_1
        AND #BTN_A+BTN_B
        BEQ @txt_input_next_end
            ora_adr txt_flags, #TXT_FLAG_INPUT
        @txt_input_next_end:
        ; is button B pressed ?
        LDA buttons_1
        AND #BTN_B
        BEQ @txt_input_skip_end
            ora_adr txt_flags, #TXT_FLAG_SKIP
        @txt_input_skip_end:

    @input_end:
