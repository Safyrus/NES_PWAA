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
    ; Game: Debug Image
    ; --------
    ;
    JSR clear_dialog
    ; test display
    LDX #COURTROOM_0
    JSR display_bkg
    LDX #<PHOENIX_DOCUMENT_A_
    LDY #>PHOENIX_DOCUMENT_A_
    JSR display_anim
