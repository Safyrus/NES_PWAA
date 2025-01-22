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
    ; draw_packets(prio=true)
    LDA #$80
    STA draw_packet_var+0 ; @cur_prio
    mov packet_max_scanline, #SCANLINE_TOP_MIDBOX
    JSR draw_packets
    ; draw_packets(prio=false)
    LDA #$00
    STA draw_packet_var+0 ; @cur_prio
    mov packet_max_scanline, #SCANLINE_DIALOG
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

    ; --------
    ; Timers
    ; --------
    ; if anim_timer > 0
    LDA anim_timer
    BEQ :+
        ; anim_timer--
        DEC anim_timer
    :
    ; if text_wait > 0
    LDA text_wait
    BEQ :+
        ; text_wait--
        DEC text_wait
    :
    ; if buttons_1_timer > 0
    LDA buttons_1_timer
    BEQ :+
        ; buttons_1_timer--
        DEC buttons_1_timer
    :
    ; if shake_timer > 0
    LDA shake_timer
    BEQ :+
        ; shake_timer--
        DEC shake_timer
    :

    ; ----------------
    ; Update Text
    ; ----------------
    ; if not busy
    LDA txt_flags
    BNE :+
        JSR read
    :

    ; ----------------
    ; Update other things
    ; ----------------
    ; update palettes
    JSR update_palettes
    ; update shake
    JSR update_shake
