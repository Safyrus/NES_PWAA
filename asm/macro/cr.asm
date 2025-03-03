.macro next_evi
    .local @while
    .local @ret
    .local @check
    ; while true
    @while:
        ; cr_idx++
        INC cr_idx
        ; if cr_idx > 127
        LDA cr_idx
        BPL @check
            ; cr_idx = 0
            LDA #$00
            STA cr_idx
        @check:
        ; if evidence_flags[cr_idx]
        JSR get_evidence_flag
            ; return
            BNE @ret
        ; continue
        JMP @while
    ; return
    @ret:
.endmacro


.macro prev_evi
    .local @while
    .local @ret
    .local @check
    ; while true
    @while:
        ; cr_idx--
        DEC cr_idx
        ; if cr_idx < 0
        LDA cr_idx
        BPL @check
            ; cr_idx = 127
            LDA #$7F
            STA cr_idx
        @check:
        ; if evidence_flags[cr_idx]
        JSR get_evidence_flag
            ; return
            BNE @ret
        ; continue
        JMP @while
    ; return
    @ret:
.endmacro
