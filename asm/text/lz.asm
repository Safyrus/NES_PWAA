; description:
;   decode a lz encoded text
;   and save the result into ram.
lz_decode:
    pushregs

    ; ----------------
    ; Initialization
    ; ----------------
    ; enable NMI_FORCE flag
    ; ora_adr nmi_flags, #NMI_FORCE

    ; ----------------
    ; Setup variables
    ; ----------------
    ; lz_out = MMC5_RAM
    sta_ptr lz_out, MMC5_RAM
    ; X = lz_idx
    LDX lz_idx
    ; lz_bnk = lz_bnk_table[X]
    LDA lz_bnk_table, X
    STA lz_bnk
    ; lz_in = lz_adr_table[X]
    LDA lz_adr_table_lo, X
    STA lz_in+0
    LDA lz_adr_table_hi, X
    STA lz_in+1
    ; save banks
    push mmc5_banks+0
    push mmc5_banks+1
    push mmc5_banks+2
    ; set output bank
    LDA #TEXT_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; set input bank
    LDX lz_bnk
    STX mmc5_banks+1
    STX MMC5_PRG_BNK0
    INX
    STX mmc5_banks+2
    STX MMC5_PRG_BNK1
    ; lz_size = *lz_in
    LDY #$00
    LDA (lz_in), Y
    STA lz_size+0
    INY
    LDA (lz_in), Y
    STA lz_size+1
    DEY
    ; lz_in += 2
    add_A2ptr lz_in, #$02

    ; ----------------
    ; Decoding
    ; ----------------
    ; while lz_size > 0 (not end_of_block)
    @while:
        LDA lz_size+0
        BNE @do
        LDA lz_size+1
        BEQ @end

        @do:
        ; decrease block size
        dec_16 lz_size+0
        ; read next byte from input
        LDA (lz_in), Y
        TAX
        ; increment input pointer
        inc_16 lz_in

        ; if bit 7 is clear
        ASL
        BCS @pointer
        @char:
            ; then output the byte as a character
            TXA
            STA (lz_out), Y
            ; increment output pointer
            inc_16 lz_out
            ;
            JMP @while

        ; else this is a pointer
        @pointer:
            ; get second byte from input
            LDA (lz_in), Y
            STA lz_buf+0
            inc_16 lz_in
            ; get the jump size (high)
            TXA
            AND #$0F
            STA lz_buf+1
            LDA lz_out+1
            sub lz_buf+1
            STA lz_buf+1
            ; get the jump size (low)
            LDA lz_out+0
            CMP lz_buf+0
            bge @dec_end_1
                DEC lz_buf+1
            @dec_end_1:
            sub lz_buf+0
            STA lz_buf+0
            bnz @dec_end_2
                DEC lz_buf+1
            @dec_end_2:
            DEC lz_buf+0
            ; get the string length
            TXA
            ASL
            shift LSR, 5
            add #$03
            TAX
            ; recover the string and output it
            @copy:
                ; read char from buffer
                LDA (lz_buf+0), Y
                ; save char to output
                STA (lz_out), Y
                ; increment buffer pointer
                inc_16 lz_buf+0
                ; increment output pointer
                inc_16 lz_out
                ; next
                DEX
                bnz @copy
            ;
            JMP @while
    @end:

    ; restore banks
    pull mmc5_banks+2
    STA MMC5_PRG_BNK1
    pull mmc5_banks+1
    STA MMC5_PRG_BNK0
    pull mmc5_banks+0
    STA MMC5_RAM_BNK

    ; disable NMI_FORCE flag
    ; and_adr nmi_flags, #($FF-NMI_FORCE)

    ; return
    pullregs
    RTS
