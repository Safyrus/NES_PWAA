    @normal_input:
        ; clear TXT_FLAG_INPUT flag
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
            LDA cr_flag
            AND #CR_FLAG_ACCESS
            BEQ @txt_input_cr_end
                ; then set/clear court record show flag
                ora_adr cr_flag, #CR_FLAG_SHOW
                ; and draw/undraw the court record
                JSR update_court_record_box
                JMP @input_end
        @txt_input_cr_end:
        ; is button DOWN pressed ?
        LDA buttons_1
        AND #BTN_DOWN
        BEQ @txt_holdit_end
            ; if this dialog is a Cross-Examination
            LDA cr_flag
            AND #CR_FLAG_OBJ
            BEQ @txt_holdit_end
                ; then 'Hold-It!'
                ; by activating the 'hold-it' dialog flag
                LDA #TXT_FLG_HOLDIT
                JSR set_dialog_flag
                ; and simulate an 'next dialog' input
                ora_adr txt_flags, #TXT_FLAG_INPUT
        @txt_holdit_end:
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
