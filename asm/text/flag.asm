_dialog_flag_start:
    ;
    PHA
    shift LSR, 3
    TAX
    ;
    PLA
    AND #$07
    TAY
    LDA #$01
    CPY #$00
    BEQ @loop_end
    @loop:
        ASL
        DEY
        BNE @loop
    @loop_end:
    RTS

; param:
; A = index
set_dialog_flag:
    JSR _dialog_flag_start
    ORA dialog_flags, X
    STA dialog_flags, X
    RTS

; param:
; A = index
clear_dialog_flag:
    JSR _dialog_flag_start
    EOR #$FF
    AND dialog_flags, X
    STA dialog_flags, X
    RTS

; param:
; A = index
; return: set Z flag if flag clear
get_dialog_flag:
    PHA
    shift LSR, 3
    TAX
    PLA
    AND #$07
    TAY
    LDA dialog_flags, X
    CPY #$00
    BEQ @loop_end
    @loop:
        LSR
        DEY
        BNE @loop
    @loop_end:
    AND #$01
    RTS