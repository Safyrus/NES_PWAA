fetch_overflow_correction:
    CMP #$A0
    blt :+
        ; adr -= $2000
        SBC #$20
        STA tmp+1
        ; bnk++
        ; MMC5_BNK1++
        INC mmc5_banks+1
        LDA mmc5_banks+1
        STA MMC5_PRG_BNK0
        ; MMC5_BNK2++
        INC mmc5_banks+2
        LDA mmc5_banks+2
        STA MMC5_PRG_BNK1
    :
    RTS
