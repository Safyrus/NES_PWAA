choice_highlight:
    ; choice highlight
    LDA max_choice
    bze @choice_highlight_end
        ; wait to be in frame
        @choice_highlight_inframe:
            BIT scanline
            BVC @choice_highlight_inframe
        ; tmp = EXP_RAM + $281
        sta_ptr tmp, (MMC5_EXP_RAM+$281)

        ;
        LDX #$00
        LDY #$00
        @choice_highlight_loop:
            ;
            TXA
            CMP choice
            BNE @choice_highlight_no
            @choice_highlight_yes:
                LDA #$00
                JMP @choice_highlight_set
            @choice_highlight_no:
                LDA #$C0
            @choice_highlight_set:
            STA (tmp), Y
            ; tmp += $40
            add_A2ptr tmp, #$40
            ; next
            INX
            CPX max_choice
            BNE @choice_highlight_loop
    @choice_highlight_end: