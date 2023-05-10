; case SND
@SND:
    ; s = next_char()
    JSR read_next_char
    STA sound
    ; ; push bank
    LDA mmc5_banks+2
    PHA
    ; set $C000 to the correct sfx bank
    LDA #MUS_SFX
    STA mmc5_banks+3
    STA MMC5_PRG_BNK2
    ; play_sound(s)
    LDX #FAMISTUDIO_SFX_CH1
    LDA sound
    JSR famistudio_sfx_play
    ; ; pull bank
    PLA
    STA mmc5_banks+3
    STA MMC5_PRG_BNK2
    ; return
    RTS
