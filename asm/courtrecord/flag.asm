_evidence_flag_start:
    ;
    PHA
    shift LSR, 3
    TAX
    LDA evidence_flags, X
    STA tmp
    ;
    PLA
    AND #$07
    TAY
    LDA #$01
    @loop:
        CPY #$00
        BEQ @loop_end
        ASL
        DEY
        JMP @loop
    @loop_end:
    RTS

; param:
; A = index
set_evidence_flag:
    push tmp
    JSR _evidence_flag_start
    ORA tmp
    STA evidence_flags, X
    pull tmp
    RTS

; param:
; A = index
clear_evidence_flag:
    push tmp
    JSR _evidence_flag_start
    EOR #$FF
    AND tmp
    STA evidence_flags, X
    pull tmp
    RTS

; param:
; A = index
; return: set Z flag of the 6502
get_evidence_flag:
    PHA
    shift LSR, 3
    TAX
    PLA
    AND #$07
    TAY
    LDA evidence_flags, X
    @loop:
        CPY #$00
        BEQ @loop_end
        LSR
        DEY
        JMP @loop
    @loop_end:
    AND #$01
    RTS