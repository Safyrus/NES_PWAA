; X = char
exec_char:
    ; - - - - - - - -
    ; switch (c)
    ; - - - - - - - -
    ; push return adr
    LDA #>(@ret-1)
    PHA
    LDA #<(@ret-1)
    PHA
    ; push jump adr
    LDA @switch_hi, X
    PHA
    LDA @switch_lo, X
    PHA
    ; jump
    @ret:
    RTS

    @switch_lo:
        .byte <(END-1)  ; $00
        .byte <(LB-1)   ; $01
        .byte <(DB-1)   ; $02
        .byte <(FDB-1)  ; $03
        .byte <(TD-1)   ; $04
        .byte <(SET-1)  ; $05
        .byte <(CLR-1)  ; $06
        .byte <(SAK-1)  ; $07
        .byte <(SPD-1)  ; $08
        .byte <(DL-1)   ; $09
        .byte <(NAM-1)  ; $0A
        .byte <(FLH-1)  ; $0B
        .byte <(FAD-1)  ; $0C
        .byte <(SAV-1)  ; $0D
        .byte <(COL-1)  ; $0E
        .byte <(RET-1)  ; $0F
        .byte <(BIP-1)  ; $10
        .byte <(MUS-1)  ; $11
        .byte <(SND-1)  ; $12
        .byte <(PHT-1)  ; $13
        .byte <(CHR-1)  ; $14
        .byte <(@ret-1) ; $15
        .byte <(BKG-1)  ; $16
        .byte <(FNT-1)  ; $17
        .byte <(JMP_-1) ; $18
        .byte <(@ret-1) ; $19
        .byte <(@ret-1) ; $1A
        .byte <(@ret-1) ; $1B
        .byte <(@ret-1) ; $1C
        .byte <(@ret-1) ; $1D
        .byte <(@ret-1) ; $1E
        .byte <(@ret-1) ; $1F
    
    @switch_hi:
        .byte >(END-1)  ; $00
        .byte >(LB-1)   ; $01
        .byte >(DB-1)   ; $02
        .byte >(FDB-1)  ; $03
        .byte >(TD-1)   ; $04
        .byte >(SET-1)  ; $05
        .byte >(CLR-1)  ; $06
        .byte >(SAK-1)  ; $07
        .byte >(SPD-1)  ; $08
        .byte >(DL-1)   ; $09
        .byte >(NAM-1)  ; $0A
        .byte >(FLH-1)  ; $0B
        .byte >(FAD-1)  ; $0C
        .byte >(SAV-1)  ; $0D
        .byte >(COL-1)  ; $0E
        .byte >(RET-1)  ; $0F
        .byte >(BIP-1)  ; $10
        .byte >(MUS-1)  ; $11
        .byte >(SND-1)  ; $12
        .byte >(PHT-1)  ; $13
        .byte >(CHR-1)  ; $14
        .byte >(@ret-1) ; $15
        .byte >(BKG-1)  ; $16
        .byte >(FNT-1)  ; $17
        .byte >(JMP_-1) ; $18
        .byte >(@ret-1) ; $19
        .byte >(@ret-1) ; $1A
        .byte >(@ret-1) ; $1B
        .byte >(@ret-1) ; $1C
        .byte >(@ret-1) ; $1D
        .byte >(@ret-1) ; $1E
        .byte >(@ret-1) ; $1F

