CHR:
    ; bl = read_char()
    JSR read_char
    ASL
    STA tmp_chr+0
    ; bh = read_char()
    JSR read_char
    ; tmp_chr = bl + (bh << 7)
    CLC
    ROR
    STA tmp_chr+1
    LDA tmp_chr+0
    ROR
    STA tmp_chr+0

    ; if new_chr == tmp_chr
    CMP new_chr+0
    BNE :+
    LDA tmp_chr+1
    CMP new_chr+1
    BNE :+
        ; tmp_chr = <0
        LDA #$FF
        STA tmp_chr+1
    :

    ; new_chr = tmp_chr
    mov new_chr+0, tmp_chr+0
    mov new_chr+1, tmp_chr+1
    
    ; return
    RTS
