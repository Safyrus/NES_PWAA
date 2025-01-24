; A = bank number
famistudio_dpcm_bank_callback:
    ; dpcm_bnk = bank number + DPCM_BNK
    add #DPCM_BNK
    STA dpcm_bnk
    STA MMC5_RAM_BNK+DPCM_BNK_OFF
    STA mmc5_banks+3
    ; return
    RTS
