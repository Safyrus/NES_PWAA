    ; --------
    ; PPU
    ; --------
    ; render background + scroll + palette + sprites
    mov nmi_flags, #(NMI_BKG + NMI_SCRL + NMI_PLT + NMI_SPR)
    mov PPU_MASK, #(PPU_MASK_BKG + PPU_MASK_BKG8 + PPU_MASK_SPR + PPU_MASK_SPR8)
    ; enable 8*16 sprites
    LDA ppu_ctrl_val
    ORA #PPU_CTRL_SPR_SIZE
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
    ; Game:Image
    ; --------
    ; gray palette
    LDA #$0F
    STA palettes+0
    LDA #$10
    STA palettes+2
    STA palettes+2+3
    STA palettes+2+3+3
    LDA #$20
    STA palettes+3
    STA palettes+3+3
    STA palettes+3+3+3

    ; init packet pointers
    LDA #$60
    STA packet_buf_read_adr+1
    STA packet_buf_write_adr+1
    ; decode 2nd image
    mov MMC5_PRG_BNK1, #IMG_BNK
    STA mmc5_banks+2
    mov MMC5_RAM_BNK, #IMG_BUF_BNK
    STA mmc5_banks+0
    mov tmp+0, #$D3
    mov tmp+1, #$A4
    mov tmp+2, #<(IMG_BKG_LO_ADR+$60)
    mov tmp+3, #>(IMG_BKG_LO_ADR+$60)
    mov tmp+4, #<$700
    mov tmp+5, #>$700
    mov tmp+6, #<(IMG_BKG_HI_ADR+$60)
    mov tmp+7, #>(IMG_BKG_HI_ADR+$60)
    mov tmp+8, #<$780
    mov tmp+9, #>$780
    JSR snif_decode
    ; display image
    JSR update_all_image

