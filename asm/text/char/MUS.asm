MUS:
    ; m = read_char()
    JSR read_char
    ; if m == music
    CMP music
    STA music
    BNE play_music
        ; pause = !pause
        LDA pause
        EOR #$FF
        STA pause
        ; famistudio_music_pause(pause)
        JSR famistudio_music_pause
        JMP :+
    ; else
    play_music:
        TAX
        ; push bank
        push mmc5_banks+2
        ; and setup music data bank
        LDA music_bank_table, X
        STA mmc5_banks+2
        STA MMC5_PRG_BNK1
        ; famistudio_init(NTSC, $A000)
        TXA
        PHA
        LDA #$FF
        LDX #<$A000
        LDY #>$A000
        JSR famistudio_init
        ; famistudio_music_play(music_idx_table[m])
        PLA
        TAX
        LDA music_idx_table, X
        JSR famistudio_music_play
        ; disable pause
        mov pause, #$00
        ; restore bank
        pull mmc5_banks+2
        STA MMC5_PRG_BNK1
    :
    ; music = m

    ; return
    RTS
