read_char:
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
    ; return
    RTS
