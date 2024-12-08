read_char:
    ; set text bank
    push mmc5_banks+0
    LDA #TEXT_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; c = *txt_ptr
    LDY #$00
    LDA (txt_ptr), Y
    ; txt_ptr++
    INC txt_ptr+0
    BNE :++
        INC txt_ptr+1
    ; if txt_ptr >= $8000 (out of text)
        TAY ; save read char
        LDA txt_ptr+1
        BPL :+
            ; lz_idx += 1
            INC lz_idx
            ; lz_decode()
            JSR lz_decode
            ; txt_ptr = MMC5_RAM
            sta_ptr txt_ptr, MMC5_RAM
        :
        TYA ; restore read char
    :
    ; restore bank
    TAY
    PLA
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    TYA
    LDY #$00
    ; return
    RTS
