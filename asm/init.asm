    ; --------
    ; PPU
    ; --------
    ; render background + scroll + palette + sprites
    mov nmi_flags, #(NMI_BKG + NMI_SCRL + NMI_PLT + NMI_SPR)
    mov PPU_MASK, #(PPU_MASK_BKG + PPU_MASK_BKG8 + PPU_MASK_SPR + PPU_MASK_SPR8)
    ; enable 8*16 sprites and switch to nametable 1
    LDA ppu_ctrl_val
    ORA #PPU_CTRL_SPR_SIZE | PPU_CTRL_NM_1
    STA ppu_ctrl_val
    STA PPU_CTRL

    ; init res_bnk array
    mov n_nonres_bnk, #$08
    LDX #$07
    LDA #$FF
    @init_res_bnk:
        STA res_bnks, X
        DEX
        BPL @init_res_bnk

    ; setup HP
    DEC hp_evt_t

    ; --------
    ; Game: Image
    ; --------
    mov sav_chr+1, #$FF
    ; init packet pointers
    LDA #$60
    STA packet_buf_read_adr+1
    STA packet_buf_write_adr+1

    ; setup name display
    DEC text_name ; =$FF
    JSR change_name

    ; setup photo
    DEC cur_photo ; =$FF
    DEC new_photo ; =$FF
    LDA #$80
    STA evi_off_x
    LDA #$20
    STA evi_off_y

    ; --------
    ; Game: Text
    ; --------
    ; init text data
    JSR lz_decode
    ; init text variables
    mov text_speed, #DEFAULT_TEXT_SPEED
    mov text_font, #DEFAULT_TEXT_FONT
    mov text_color, #DEFAULT_TEXT_COLOR
    mov text_box_bnk, #IMG_BUF_BNK
    mov text_ppu_start+0, #$60
    mov text_ppu_start+1, #$02
    ;
    JSR dialog_reset
    ; txt_ptr = MMC5_RAM
    sta_ptr txt_ptr, MMC5_RAM

    ; --------
    ; Game: Debug Image
    ; --------
    ; disable animation
    mov cur_chr+1, #$FF
    STA new_chr+1
    ; test display
    LDX #BKG_EMPTY
    STX new_bkg
    JSR display_bkg
    ; LDX #<OUT_R0_CHAR_PHOENIX_PHOENIX_DOCUMENT_A__I0T8
    ; LDY #>OUT_R0_CHAR_PHOENIX_PHOENIX_DOCUMENT_A__I0T8
    ; JSR display_chr
    ; LDX #<OUT_R0_CHAR_PHOENIX_PHOENIX_CONFIDENT_B_
    ; STX new_chr+0
    ; LDY #>OUT_R0_CHAR_PHOENIX_PHOENIX_CONFIDENT_B_
    ; STY new_chr+1
    ; JSR display_anim
    JSR call_update_img

    ; --------
    ; FamiStudio
    ; --------
    ; sfx_chn = FAMISTUDIO_SFX_CH0
    mov sfx_chn, #FAMISTUDIO_SFX_CH0
    ; push bank
    push mmc5_banks+1
    ; and setup sfx data bank
    LDA #SFX_BNK
    STA mmc5_banks+1
    STA MMC5_PRG_BNK0
    ; famistudio_init(NTSC, dpcm_data)
    LDA #$FF
    LDX #<dpcm_data
    LDY #>dpcm_data
    JSR famistudio_init
    ; famistudio_sfx_init($8000)
    LDX #<$8000
    LDY #>$8000
    JSR famistudio_sfx_init
    ; fs_dpcm_sfx_ptr = famistudio_dpcm_list
    mov fs_dpcm_sfx_ptr+0, famistudio_dpcm_list_lo
    mov fs_dpcm_sfx_ptr+1, famistudio_dpcm_list_hi
    ; restore bank
    pull mmc5_banks+1
    STA MMC5_PRG_BNK0


    ; --------
    ; Sound
    ; --------
    ; setup music
    LDA #$00
    JSR play_music
    LDA #$FF
    STA pause
    JSR famistudio_music_pause
    ; disable BIP
    mov bip, #$FF ; should be $FF


    ; --------
    ; Other
    ; --------
    ; enable text
    and_adr txt_flags, #($FF-$01)
