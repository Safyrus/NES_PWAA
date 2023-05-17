; case SND
@SND:
    ; s = next_char()
    JSR read_next_char
    STA sound
    ; ; push bank
    LDA mmc5_banks+SFX_BNK_OFF
    PHA
    ; set the correct sfx bank
    LDA #MUS_SFX
    STA mmc5_banks+SFX_BNK_OFF
    STA MMC5_RAM_BNK+SFX_BNK_OFF
    ; play_sound(s)
    LDX #FAMISTUDIO_SFX_CH1
    LDA sound
    JSR famistudio_sfx_play
    ; ; pull bank
    PLA
    STA mmc5_banks+SFX_BNK_OFF
    STA MMC5_RAM_BNK+SFX_BNK_OFF
    ; return
    RTS
