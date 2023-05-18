    ; render background + scroll + palette + sprites
    mov nmi_flags, #(NMI_BKG + NMI_SCRL + NMI_PLT + NMI_SPR)
    mov PPU_MASK, #(PPU_MASK_BKG + PPU_MASK_BKG8 + PPU_MASK_SPR + PPU_MASK_SPR8)
    ; enable 8*16 sprites
    LDA ppu_ctrl_val
    ORA #PPU_CTRL_SPR_SIZE
    STA ppu_ctrl_val
    STA PPU_CTRL

    ; init famistudio with fake music
    LDX #<$A000
    LDY #>$A000
    mov MMC5_PRG_BNK1, #MUS_BNK
    JSR famistudio_init
    ; init famistudio sfx
    mov MMC5_RAM_BNK+SFX_BNK_OFF, #MUS_SFX
    LDX #<sounds
    LDY #>sounds
    JSR famistudio_sfx_init
    mov MMC5_RAM_BNK+SFX_BNK_OFF, #CODE_BNK

    ; set dialog box palette
    mov palettes+10, #$00
    mov palettes+11, #$10
    mov palettes+12, #$30

    ; load and draw image
    JSR find_anim
    JSR frame_decode

    ; load first dialog block
    mov lz_in_bnk, #TXT_BNK
    sta_ptr lz_in, $A000
    JSR lz_decode

    ; - - - - - - - -
    ; init print variables
    ; - - - - - - - -
    ; ext value = $C0
    mov print_ext_val, #$C0
    ; print_counter = 0
    mov print_counter, #$00
    ;
    JSR read_next_dailog

    ; draw dialog box
    JSR draw_dialog_box

    ; init text read pointer
    mov lz_idx, #$00
    JSR lz_init
    sta_ptr txt_rd_ptr, MMC5_RAM
    ; enable READY flag
    ora_adr txt_flags, #TXT_FLAG_READY
