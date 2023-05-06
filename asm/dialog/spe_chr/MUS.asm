; case MUS
@MUS:
    ; m = next_char()
    JSR read_next_char
    STA music
    TAX
    ; push bank
    LDA mmc5_banks+2
    PHA
    ; set $A000 to the correct music bank
    LDA music_bank_table, X
    STA mmc5_banks+2
    STA MMC5_PRG_BNK1
    ; if m > 0
    TXA
    bze @MUS_stop_mus
    @MUS_play_mus:
        ; init famistudio music
        LDX #<$A000
        LDY #>$A000
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
    STA mmc5_banks+2
    STA MMC5_PRG_BNK1
    ; return
    RTS
