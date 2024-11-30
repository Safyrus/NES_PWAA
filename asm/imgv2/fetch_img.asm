
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
    ; MMC5_BNK1, MMC5_BNK2 = bnk, bnk+1
    STA MMC5_PRG_BNK1
    STA mmc5_banks+2
    INY
    STY MMC5_PRG_BNK2
    STY mmc5_banks+3
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
    JSR fetch_overflow_correction
    inc_16 @adr
    JSR fetch_overflow_correction

    ; return bnk, adr
    RTS
