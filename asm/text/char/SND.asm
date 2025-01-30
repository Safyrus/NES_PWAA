.segment "LAST_BNK"
SND:
    ; s = read_char()
    JSR read_char
    TAX
; X = sfx
play_sfx:
    ; setup sfx data bank
    LDA #SFX_BNK
    STA MMC5_PRG_BNK0

    ; if s.dpcm
    TXA
    AND #$40
    BNE @dpcm
    @sfx:
        ; famistudio_sfx_play(s, sfx_chn)
        TXA
        LDX sfx_chn
        JSR famistudio_sfx_play
        JMP :+
    @dpcm:
        ; push famistudio_dpcm_list
        push famistudio_dpcm_list_lo
        push famistudio_dpcm_list_hi
        ; famistudio_dpcm_list = fs_dpcm_sfx_ptr
        mov famistudio_dpcm_list_lo, fs_dpcm_sfx_ptr+0
        mov famistudio_dpcm_list_hi, fs_dpcm_sfx_ptr+1
        ; famistudio_sfx_sample_play(s)
        TXA
        AND #$3F
        JSR famistudio_sfx_sample_play
        ; pull famistudio_dpcm_list
        pull famistudio_dpcm_list_hi
        pull famistudio_dpcm_list_lo
    :

    ; restore bank
    LDA #CODE_BNK
    STA MMC5_PRG_BNK0
    ; return
    RTS

.segment "CODE_BNK"
