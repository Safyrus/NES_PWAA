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

    ; --------
    ; Game: Image
    ; --------
    ; init packet pointers
    LDA #$60
    STA packet_buf_read_adr+1
    STA packet_buf_write_adr+1

    ; setup name display
    DEC text_name ; =$FF
    LDA #NAME_COL_1
    STA img_tmp_pals+(7*3)+1
    LDA #NAME_COL_2
    STA img_tmp_pals+(7*3)+2
    LDA #NAME_COL_3
    STA img_tmp_pals+(7*3)+3
    JSR change_name

    ; setup photo
    DEC cur_photo ; =$FF
    DEC new_photo ; =$FF

    ; --------
    ; Game: Text
    ; --------
    ; init text data
    JSR lz_decode
    ; init text variables
    mov text_speed, #DEFAULT_TEXT_SPEED
    mov text_font, #DEFAULT_TEXT_FONT
    mov text_color, #DEFAULT_TEXT_COLOR
    ;
    JSR dialog_reset
    ; txt_ptr = MMC5_RAM
    sta_ptr txt_ptr, MMC5_RAM

    ; --------
    ; Game: Debug Image
    ; --------
    ; test display
    LDX #COURTROOM_0
    STX new_bkg
    JSR display_bkg
    LDX #<PHOENIX_DOCUMENT_A_
    STX new_chr+0
    LDY #>PHOENIX_DOCUMENT_A_
    STY new_chr+1
    JSR display_anim
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
    ; Other
    ; --------
    ; disable BIP
    mov bip, #$FF ; should be $FF
    ; enable text
    and_adr txt_flags, #($FF-TXT_FLAG_BUSY)
