; case EVT
EVT:
    ; e = next_char()
    JSR read_next_char
    BMI @EVT_end ; return if async lz() has been called
    CMP #MAX_EVENT
    bge @EVT_end

    ; if TXT_FLAG_SKIP
    BIT txt_flags
    BVC :+
        CMP #EVT_CHR::CR
        BEQ @EVT_end
        CMP #EVT_CHR::CR_OBJ
        BEQ @EVT_end
        CMP #EVT_CHR::CLICK
        BEQ @EVT_end

        JMP read_next_char
    :

    TAX
    ; jump event_table[e]
    LDA @evt_jmp_hi, X
    PHA
    LDA @evt_jmp_lo, X
    PHA
    @EVT_end:
    RTS

    @evt_jmp_lo:
        .byte <(@EVT_cr-1)
        .byte <(@EVT_cr_obj-1)
        .byte <(@EVT_cr_set-1)
        .byte <(@EVT_cr_clr-1)
        .byte <(@EVT_cr_idx-1)
        .byte <(@EVT_click-1)
        .byte <(@EVT_act_ret-1)
    @evt_jmp_hi:
        .byte >(@EVT_cr-1)
        .byte >(@EVT_cr_obj-1)
        .byte >(@EVT_cr_set-1)
        .byte >(@EVT_cr_clr-1)
        .byte >(@EVT_cr_idx-1)
        .byte >(@EVT_click-1)
        .byte >(@EVT_act_ret-1)

    @EVT_cr:
        eor_adr cr_flag, #CR_FLAG_ACCESS
        RTS
    @EVT_cr_obj:
        eor_adr cr_flag, #CR_FLAG_OBJ
        RTS
    @EVT_cr_set:
        JSR read_next_char
        JMP set_evidence_flag
    @EVT_cr_clr:
        JSR read_next_char
        JMP clear_evidence_flag
    @EVT_cr_idx:
        JSR read_next_char
        STA cr_correct_idx
        RTS
    @EVT_click:
        ; set investigation flag
        ora_adr click_flag, #CLICK_ENA
        RTS
    @EVT_act_ret:
        ora_adr input_flags, #ACT_RET_FLAG
        RTS
