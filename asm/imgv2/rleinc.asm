
; return in A the byte read and increase the ptr
; need Y to be 0
rleinc_next:
    LDA (tmp), Y
    ; increase pointer
    INC tmp+0
    BNE @end
        INC tmp+1
        PHA
        LDA tmp+1
        AND #$1F
        BNE @ret
            INC mmc5_banks+2
            mov MMC5_PRG_BNK1, mmc5_banks+2
            LDA tmp+1
            sub #$20
            STA tmp+1
        @ret:
        PLA
    @end:
    RTS

; description:
;   decode a RLEINC stream of data
;   This variant of RLEINC is close to the one found on the NesDev wiki (https://www.nesdev.org/wiki/Tile_compression).
;   The only change is that the LIT command read bytes forewards instead of backwards.
;
;   | Value | Meaning
;   | 00-3F | LIT: Copy (n+1) bytes from input to output
;   | 40    | END: End of stream
;   | 41-7F | SEQ: Read next byte b. Put b, (n-0x3F) times; add 1 to b after each iteration
;   | 80-9F | DBL: Read next byte b1, and next byte b2. Put b1, (n-0x7D) times; swap b2 and b1 after each iteration
;   | A0-FF | RUN: Read byte b. Put b, (0x101-n) times. 
; params:
; - tmp[0..1] = in ptr
; - tmp[2..3] = out ptr
; use tmp[0..5]
rleinc:
    pushregs

    ; enable NMI_FORCE flag
    ora_adr nmi_flags, #NMI_FORCE

    ; while true
    LDY #$00
    @while:
        ; b = rleinc_next()
        JSR rleinc_next
        ; save b
        TAX
        ; decode command
        ASL
        BCS @dbl_or_run
        BMI @seq_or_end
        @LIT:
            ; for b
            @lit_loop:
                ; copy
                JSR rleinc_next
                STA (tmp+2), Y
                inc_16 tmp+2
                ; continue
                DEX
                BPL @lit_loop
            JMP @while
        @seq_or_end:
            CMP #$80 ; $80 instead of $40 because we have shift 1 to the left
            BEQ @END
        @SEQ:
            ; b = b & 0x3F
            ASL
            LSR
            LSR
            ; n = b + 1
            TAX
            ; b = rleinc_next()
            JSR rleinc_next
            ; for n
            @seq_loop:
                ; copy
                STA (tmp+2), Y
                inc_16 tmp+2
                ; inc
                add #$01
                ; continue
                DEX
                BPL @seq_loop
            JMP @while
        @dbl_or_run:
            ASL
            BCS @RUN
            BMI @RUN
        @DBL:
            ; n = b−0x7D
            LSR
            LSR
            TAX
            INX
            INX
            ; b1 = rleinc_next()
            JSR rleinc_next
            STA tmp+4
            ; b2 = rleinc_next()
            JSR rleinc_next
            STA tmp+5
            ; for n
            @dbl_loop:
                ; copy b1
                LDA tmp+4
                STA (tmp+2), Y
                inc_16 tmp+2
                ; continue
                DEX
                BMI @dbl_loop_end
                ; copy b2
                LDA tmp+5
                STA (tmp+2), Y
                inc_16 tmp+2
                ; continue
                DEX
                BPL @dbl_loop
            @dbl_loop_end:
            JMP @while
        @RUN:
            ; n = 0x101 - b
            TXA
            EOR #$FF
            TAX
            INX
            ; b = rleinc_next()
            JSR rleinc_next
            ; for n
            @run_loop:
                ; copy b
                STA (tmp+2), Y
                inc_16 tmp+2
                ; continue
                DEX
                BPL @run_loop
            JMP @while

    @END:

    ; disable NMI_FORCE flag
    and_adr nmi_flags, #($FF-NMI_FORCE)

    pullregs
    RTS
