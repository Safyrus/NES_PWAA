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
    ; FamiStudio
    ; --------
    ; init famistudio with fake music
    LDX #<$A000
    LDY #>$A000
    mov MMC5_PRG_BNK1, #MUS_BNK
    JSR famistudio_init
    ; init famistudio sfx
    mov MMC5_RAM_BNK+SFX_BNK_OFF, #SFX_BNK
    LDX #<sounds
    LDY #>sounds
    JSR famistudio_sfx_init
    mov MMC5_RAM_BNK+SFX_BNK_OFF, #CODE_BNK

    ; --------
    ; Game: Image
    ; --------
    ; init packet pointers
    LDA #$60
    STA packet_buf_read_adr+1
    STA packet_buf_write_adr+1

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
    LDY #>PHOENIX_DOCUMENT_A_
    JSR display_anim

    ; enable text
    and_adr txt_flags, #($FF-TXT_FLAG_BUSY)
