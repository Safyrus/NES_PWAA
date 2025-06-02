
; arg:
; X = img idx (lo)
; Y = img idx (hi)
; return:
; MMC5_BNK1 = bnk
; MMC5_BNK2 = bnk+1
; tmp+0 = adr
; X, Y = 0
; clobber A
fetch_img:
    @adr = tmp+0

    ; adr_lo = img_ptr_list_lo[y]
    LDA img_ptr_list_lo, Y
    STA @adr+0
    ; adr_hi = img_ptr_list_hi[y]
    LDA img_ptr_list_hi, Y
    STA @adr+1
    ; bnk = img_ptr_list_bnk[y]
    LDA img_ptr_list_bnk, Y
    TAY
fetch_loop:
    @adr = tmp+0
    ; MMC5_BNK1, MMC5_BNK2 = bnk, bnk+1
    STY mmc5_banks+1
    STY MMC5_PRG_BNK0
    INY
    STY mmc5_banks+2
    STY MMC5_PRG_BNK1
    ; while X > 0
    LDY #$00
    CPX #$00
    BEQ @while_end
    @while:
        ; size_hi = adr[1]
        INY
        LDA (@adr), Y
        DEY
        PHA
        ; size_lo = adr[0]
        LDA (@adr), Y
        ; adr += size
        add @adr+0
        STA @adr+0
        BCC :+
            INC @adr+1
        :
        PLA
        add @adr+1
        STA @adr+1
        ; if adr overflow
        JSR fetch_overflow_correction
        ; continue
        DEX
        BNE @while
    @while_end:

    ; skip size info
    inc_16 @adr
    inc_16 @adr
    LDA @adr+1
    JSR fetch_overflow_correction

    ; return bnk, adr
    RTS
