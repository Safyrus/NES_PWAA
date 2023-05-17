; case MUS
@MUS:
    ; m = next_char()
    JSR read_next_char
    STA music
    TAX
    ; push bank
    LDA mmc5_banks+MUS_BNK_OFF
    PHA
    ; set the correct music bank
    LDA music_bank_table, X
    STA mmc5_banks+MUS_BNK_OFF
    STA MMC5_RAM_BNK+MUS_BNK_OFF
    ; if m > 0
    TXA
    bze @MUS_stop_mus
    @MUS_play_mus:
        ; init famistudio music
        LDX #<($6000+(MUS_BNK_OFF*$2000))
        LDY #>($6000+(MUS_BNK_OFF*$2000))
        JSR famistudio_init
        ; play_music(m)
        LDX music
        LDA music_idx_table, X
        JSR famistudio_music_play
        JMP @MUS_end
    @MUS_stop_mus:
        ; stop_music()
        JSR famistudio_music_stop
    @MUS_end:
    ; pull bank
    PLA
    STA mmc5_banks+MUS_BNK_OFF
    STA MMC5_RAM+MUS_BNK_OFF
    ; return
    RTS
