_dialog_flag_start:
    ;
    PHA
    LSR
    LSR
    LSR
    TAX
    LDA dialog_flag, X
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
set_dialog_flag:
    JSR _dialog_flag_start
    ORA tmp
    STA dialog_flag, X
    RTS

; param:
; A = index
clear_dialog_flag:
    JSR _dialog_flag_start
    EOR #$FF
    AND tmp
    STA dialog_flag, X
    RTS

; param:
; A = index
; return: set Z flag of the 6502
get_dialog_flag:
    PHA
    LSR
    LSR
    LSR
    TAX
    PLA
    AND #$07
    TAY
    LDA dialog_flag, X
    @loop:
        CPY #$00
        BEQ @loop_end
        LSR
        DEY
        JMP @loop
    @loop_end:
    AND #$01
    RTS