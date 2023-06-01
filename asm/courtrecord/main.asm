.include "data.asm"
.include "draw.asm"
.include "flag.asm"

; /!\ don't save registers
inc_evidence_idx:
    ; do_while cr_idx not valid
    @while:
        ; cr_idx++
        INC cr_idx
        ; if cr_idx > MAX_EVIDENCE_IDX
        LDA cr_idx
        CMP #MAX_EVIDENCE_IDX
        blt @next
            ; cr_idx = 0
            mov cr_idx, #$00
        @next:
        ; while part
        LDA cr_idx
        JSR get_evidence_flag ; Z = evidence not obtained
        BEQ @while ; while not obtained
    @end:
    RTS

; /!\ don't save registers
dec_evidence_idx:
    ; do_while cr_idx not valid
    @while:
        ; cr_idx--
        DEC cr_idx
        ; if cr_idx < 0
        BPL @next
            ; cr_idx = MAX_EVIDENCE_IDX
            mov cr_idx, #MAX_EVIDENCE_IDX
        @next:
        ; while part
        LDA cr_idx
        JSR get_evidence_flag ; Z = evidence not obtained
        BEQ @while ; while not obtained
    @end:
    RTS


; .struct Evidence
;     ; id .byte  implicite, flag position
;     txt .word ; pointer to text description (end by `p`)
;     img .byte ; image index (same as for PHT) to find the pointer to the image (just RLE-INC with no header)
;     pad .byte ; padding
; .endstruct
