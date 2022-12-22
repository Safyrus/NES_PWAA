;**********
; Main
;**********

MAIN:

    ; init
    LDA #DIALOG_BNK
    STA lz_in_bnk
    STA MMC5_PRG_BNK0
    LDA #<TEXT_PTR
    STA lz_in+0
    LDA #>TEXT_PTR
    STA lz_in+1
    JSR lz_decode

    ; wait for next frame to start
    @wait_vblank:
        BIT nmi_flags
        BPL @wait_vblank

    ; arcknoledge nmi
    LDA nmi_flags
    AND #($FF-NMI_DONE)
    STA nmi_flags

    ; loop back to start of main
    JMP @wait_vblank
