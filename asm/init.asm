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
    LDA effect_flags
    EOR #EFFECT_FLAG_PAL_SPLIT
    STA effect_flags
    ; test display
    LDX #CUTSCENE_49
    JSR display_bkg

