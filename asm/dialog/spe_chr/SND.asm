; case SND
@SND:
    ; s = next_char()
    JSR read_next_char
    STA sound
    ; push bank
    LDA mmc5_banks+SFX_BNK_OFF
    PHA
    ; set the correct sfx bank
    LDA #MUS_SFX
    STA mmc5_banks+SFX_BNK_OFF
    STA MMC5_RAM_BNK+SFX_BNK_OFF
    ; play_sound(s)
    LDA sound
    CMP #$40
    bge @SND_dpcm
    @SND_normal:
        LDX #FAMISTUDIO_SFX_CH1
        JSR famistudio_sfx_play
        JMP @SND_end
    @SND_dpcm:
        ;
        push famistudio_dpcm_list_lo
        push famistudio_dpcm_list_hi
        sta_ptr famistudio_dpcm_list_lo, dpcm_samples
        ;
        LDA #DPCM_BNK
        STA mmc5_banks+DPCM_BNK_OFF
        STA MMC5_RAM_BNK+DPCM_BNK_OFF
        ;
        LDA sound
        AND #$3F
        JSR famistudio_sfx_sample_play
        ;
        pull famistudio_dpcm_list_hi
        pull famistudio_dpcm_list_lo
    @SND_end:
    ; pull bank
    PLA
    STA mmc5_banks+SFX_BNK_OFF
    STA MMC5_RAM_BNK+SFX_BNK_OFF
    ; return
    RTS
