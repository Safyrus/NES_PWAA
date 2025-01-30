.segment "LAST_BNK"
SND:
    ; s = read_char()
    JSR read_char
    TAX
    ; setup sfx data bank
    LDA #SFX_BNK
    STA MMC5_PRG_BNK0

    ; if s.dpcm
    TXA
    AND #$40
    BNE @dpcm
    @sfx:
        ; famistudio_sfx_play(s, FAMISTUDIO_SFX_CH0)
        TXA
        LDX #FAMISTUDIO_SFX_CH0
        JSR famistudio_sfx_play
        JMP :+
    @dpcm:
        ; famistudio_sfx_sample_play(s)
        TXA
        AND #$3F
        JSR famistudio_sfx_sample_play
    :

    ; restore bank
    LDA #CODE_BNK
    STA MMC5_PRG_BNK0
    ; return
    RTS

.segment "CODE_BNK"
