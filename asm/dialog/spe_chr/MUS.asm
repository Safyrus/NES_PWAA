; case MUS
@MUS:
    ; m = next_char()
    JSR read_next_char
    STA music
    ;
    LDA mmc5_banks+2
    PHA
    LDA #MUS_BNK
    STA mmc5_banks+2
    STA MMC5_PRG_BNK1
    ; play_music(m)
    LDA music
    bze @MUS_stop_mus
    @MUS_play_mus:
        sub #$01
        JSR famistudio_music_play
        JMP @MUS_end
    @MUS_stop_mus:
        JSR famistudio_music_stop
    @MUS_end:
    ;
    PLA
    STA mmc5_banks+2
    STA MMC5_PRG_BNK1
    RTS
