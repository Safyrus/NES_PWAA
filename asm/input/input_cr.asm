    ; if court record is displayed
    LDA cr_flag
    AND #CR_FLAG_SHOW
    BEQ @cr_end
    @cr:
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
            JSR inc_evidence_idx
            ; update the court record display
            JSR update_court_record_box
        @cr_left_end:
        ; is button LEFT pressed ?
        LDA buttons_1
        AND #BTN_LEFT
        BEQ @cr_right_end
            ; decrease evidence index
            JSR dec_evidence_idx
            ; update the court record display
            JSR update_court_record_box
        @cr_right_end:
        ; is button A pressed ?
        LDA buttons_1
        AND #BTN_A
        BEQ @txt_obj_end
            ; if this dialog is a Cross-Examination
            LDA cr_flag
            AND #CR_FLAG_OBJ
            BEQ @txt_obj_end
                ; then 'Objection!'
                ; by activating the 'objection' dialog flag
                LDA #TXT_FLG_OBJ
                JSR set_dialog_flag
                ; hide the court record (but we don't refresh the screen)
                and_adr cr_flag, #$FF-CR_FLAG_SHOW
                ; and simulate an 'next dialog' input
                ora_adr txt_flags, #TXT_FLAG_INPUT
                ; if the objection is correct
                LDA cr_idx
                CMP cr_correct_idx
                BNE @txt_obj_NOP
                @txt_obj_OK:
                    ; then set the 'objection OK' dialog flag
                    LDA #TXT_FLG_OBJ_OK
                    JSR set_dialog_flag
                    JMP @txt_obj_end
                @txt_obj_NOP:
                    ; else clear the 'objection OK' dialog flag
                    LDA #TXT_FLG_OBJ_OK
                    JSR clear_dialog_flag
        @txt_obj_end:
        ;
        JMP @input_end
    @cr_end:
