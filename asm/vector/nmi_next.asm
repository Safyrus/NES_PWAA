    ; --------
    ; Update some variables
    ; --------
    ; set nametable mapping to default
    LDA #DEFAULT_NT_MAPPING
    STA MMC5_NAMETABLE
    ; enable interrupt
    CLI

    ; --------
    ; Update FamiStudio
    ; --------
    @DEBUG_FAMISTUDIO_UPDATE_START:
    ; load music banks
    LDX music
    LDA music_bank_table, X
    STA MMC5_RAM_BNK+MUS_BNK_OFF
    mov MMC5_RAM_BNK+SFX_BNK_OFF, #SFX_BNK
    ; update famistudio
    JSR famistudio_update
    ; restore banks
    mov MMC5_RAM_BNK+MUS_BNK_OFF, mmc5_banks+MUS_BNK_OFF
    mov MMC5_RAM_BNK+SFX_BNK_OFF, mmc5_banks+SFX_BNK_OFF
    @DEBUG_FAMISTUDIO_UPDATE_END:


    ; --------
    ; Prepare next frame graphism
    ; --------
    ; set image bank
    mov MMC5_RAM_BNK, #IMG_BUF_BNK
    ; draw_packets()
    JSR draw_packets
    ; if not img_flag.unsprite
    LDA img_flag
    AND #IMG_FLAG_UNSPRITE
    BNE :+
        ; draw_sprites()
        JSR draw_sprites
    :
    ; restore bank
    mov MMC5_RAM_BNK, mmc5_banks+0

    ; if anim_timer > 0
    LDA anim_timer
    BEQ :+
        ; anim_timer--
        DEC anim_timer
    :


    ; ; read text
    ; JSR read_text
    ; ; restore ram bank
    ; LDA mmc5_banks+0
    ; STA MMC5_RAM_BNK

    ; ; print_flush if needed
    ; LDA txt_flags
    ; AND #TXT_FLAG_PRINT
    ; BEQ @print_end
    ;     push tmp
    ;     push tmp+1
    ;     JSR print_flush
    ;     pull tmp+1
    ;     pull tmp
    ;     and_adr txt_flags, #($FF-TXT_FLAG_PRINT)
    @print_end:

    ; ; flash
    ; LDA fade_timer
    ; BNE @flash_end
    ; LDA flash_timer
    ; BEQ @no_flash
    ;     LDA #$30
    ;     for_x @flash_loop_white, #$15
    ;         STA palettes, X
    ;     to_x_dec @flash_loop_white, #-1

    ;     LDA #$00
    ;     STA palettes+10
    ;     LDA #$10
    ;     STA palettes+11

    ;     DEC flash_timer
    ;     BEQ @flash_stop

    ;     JMP @flash_end
    ; @no_flash:
    ;     ; skip if palette are changed by a fade
    ;     LDA effect_flags
    ;     AND #(EFFECT_FLAG_FADE+EFFECT_FLAG_DRAW)
    ;     EOR #EFFECT_FLAG_FADE
    ;     BNE @flash_end
    ;     @flash_stop:
    ;     ; update palette 0-2 and background color
    ;     for_x @flash_loop_stop, #9
    ;         LDA img_palettes, X
    ;         STA palettes, X
    ;     to_x_dec @flash_loop_stop, #-1
    ;     ; update palette 3
    ;     mov palettes+13, img_palette_3+0
    ;     mov palettes+14, img_palette_3+1
    ;     mov palettes+15, img_palette_3+2
    ; @flash_end:
