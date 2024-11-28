
; arg:
; X = anim idx (lo)
; Y = anim idx (hi)
; return:
; MMC5_BNK1 = bnk
; MMC5_BNK2 = bnk+1
; tmp+0 = adr
; X, Y = 0
; clobber A
fetch_anim:
    @adr = tmp+0

    ; adr_lo = anim_ptr_list_lo[y]
    LDA anim_ptr_list_lo, Y
    STA @adr+0
    ; adr_hi = anim_ptr_list_hi[y]
    LDA anim_ptr_list_hi, Y
    STA @adr+1
    ; bnk = anim_ptr_list_bnk[y]
    LDA anim_ptr_list_bnk, Y
    ; MMC5_BNK1, MMC5_BNK2 = bnk, bnk+1
    STA MMC5_PRG_BNK1
    STA mmc5_banks+2
    STA MMC5_PRG_BNK2
    STA mmc5_banks+3
    ; while X > 0
    LDY #$00
    CPX #$00
    BEQ @while_end
    @while:
        ; size = adr[0]
        LDA (@adr), Y
        ; adr += size
        add @adr+0
        STA @adr+0
        BCC :+
            INC @adr+1
            ; if adr overflow
            JSR fetch_overflow_correction
        :
        ; continue
        DEX
        BNE @while
    @while_end:

    ; return bnk, adr
    RTS
