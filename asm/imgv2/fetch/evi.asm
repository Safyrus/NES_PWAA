; arg:
; X = evi idx
; return:
; MMC5_BNK1 = bnk
; MMC5_BNK2 = bnk+1
; tmp+0 = adr
; X, Y = 0
; clobber A
fetch_evi:
    @adr = tmp+0
    ; adr_lo = evi_ptr_list_lo
    LDA evi_ptr_list_lo
    STA @adr+0
    ; adr_hi = evi_ptr_list_hi
    LDA evi_ptr_list_hi
    STA @adr+1
    ; bnk = evi_ptr_list_bnk
    LDY evi_ptr_list_bnk
    ; for i=0 to X : bnk, adr += evi_list[i].size
    ; return bnk, adr
    JMP fetch_loop
