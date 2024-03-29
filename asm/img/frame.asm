frame_decode:
    pushregs

    ; tmp+2 = anim_adr
    mov_ptr tmp+2, anim_adr
    ;
    LDA anim_bnk
    STA mmc5_banks+3
    STA MMC5_PRG_BNK2

    ; is a fade effect active ?
    ; LDA fade_timer
    ; bze :+
    ;     ; then do nothing
    ;     JMP @end
    ; :

    ; ; is a fade out effect active ?
    ; LDA effect_flags
    ; AND #(EFFECT_FLAG_FADE)
    ; bnz :+
    ;     ; then do nothing
    ;     JMP @end
    ; :

    ; is the animation frame counter > 0 ?
    LDA anim_frame_counter
    bze :+
        ; then decrement it and jump to the end
        DEC anim_frame_counter
        JMP @end
    :

    ; LDY here instead of down there before branch because we are 1 byte off
    LDY #$00

    ; do we need to draw the background ?
    LDA effect_flags
    AND #EFFECT_FLAG_BKG
    bnz @load_bck

    ; does the animation have any frames ?
    LDA anim_base_adr+0
    CMP tmp+2
    beq :+
        JMP :+++
    :
    LDA anim_base_adr+1
    CMP tmp+3
    beq :+
        JMP :++
    :
    ; there is a LDY here, it is located up there
    LDA (tmp+2), Y
    LSR
    LSR
    bnz :+
        JMP @end
    :

    ; do we need to reset the animation to the start ?
    LDA anim_img_counter
    bnz @load_chr
        ; anim_adr, tmp+2 = anim_base_adr
        LDA anim_base_adr+0
        STA anim_adr+0
        STA tmp+2
        LDA anim_base_adr+1
        STA anim_adr+1
        STA tmp+3
        ; anim_img_counter = (*anim_adr) >> 2
        LDY #$00
        LDA (tmp+2), Y
        LSR
        LSR
        STA anim_img_counter
        ; anim_adr++
        inc_16 anim_adr
        inc_16 tmp+2

    ; draw the next animation frame
    @load_chr:
        ; anim_frame_counter = anim_adr[0]
        LDY #$00
        LDA (tmp+2), Y
        STA anim_frame_counter
        ; tmp+0 = anim_adr[1:2]
        INY
        LDA (tmp+2), Y
        STA tmp+0
        INY
        LDA (tmp+2), Y
        STA tmp+1
        ; MMC5_PRG_BNK1 = anim_adr[3]
        INY
        LDA (tmp+2), Y
        STA mmc5_banks+2
        STA MMC5_PRG_BNK1
        ; anim_img_counter--
        DEC anim_img_counter
        ; update anim_adr
        INY
        TYA
        add_A2ptr anim_adr
        ;
        JMP @start

    @load_bck:
        ; clear flag
        and_adr effect_flags, #($FF-EFFECT_FLAG_BKG)
        ; set image bank
        LDX img_background
        LDA img_bkg_table_bank, X
        STA mmc5_banks+2
        STA MMC5_PRG_BNK1
        ; Set pointer to image.
        ;  We only need to set it 1 time,
        ;  because the rleinc decode subroutine
        ;  will increase the pointer to the
        ;  end of the rleinc block.
        TXA
        ASL
        TAX
        LDA img_bkg_table, X
        STA tmp+0
        INX
        LDA img_bkg_table, X
        STA tmp+1

    @start:
    ; set ram bank
    mov MMC5_RAM_BNK, #IMG_BUF_BNK
    STA mmc5_banks+0

    ; - - - - - - - -
    ; read header byte
    ; - - - - - - - -
    LDY #$00
    JSR rleinc_next
    STA img_header
    ; skip partial frame flag
    ASL

    ; - - - - - - - -
    ; read palettes
    ; - - - - - - - -
    ; read next header bit
    ASL
    BCC @palette_end
    @palette:
        ; save header byte
        PHA

        ; reset counters
        LDA #$00
        STA palette_counter+0
        STA palette_counter+1
        STA palette_counter+2

        @palette_while:
            ; get color
            JSR rleinc_next
            ; if color == $FF (invalid color) then stop
            CMP #$FF
            BEQ @palette_while_end
            ; if color for the sprites palette
            CMP #$80
            blt @palette_while_chr_or_bkg
            @palette_while_spr:
                ; remove flags
                AND #$3F
                ; palette[3][X] = color
                LDX palette_counter+2
                STA img_palette_3, X
                ; X++
                INC palette_counter+2
                JMP @palette_while
            @palette_while_chr_or_bkg:
            ; if color for the character palette
            CMP #$40
            blt @palette_while_bkg
            @palette_while_chr:
                ; remove flags
                AND #$3F
                ; if X == 0
                LDX palette_counter+1
                BNE :+
                    ; palette[2][0] = color
                    STA img_palette_2
                :
                ; palette[1][X] = color
                STA img_palette_1, X
                ; X++
                INC palette_counter+1
                JMP @palette_while
            ; else it is for the background palette
            @palette_while_bkg:
                ; palette[0][X] = color
                LDX palette_counter+0
                STA img_palette_bkg, X
                ; if X >= 2
                CPX #$02
                blt :+
                    ; palette[2][X-1] = color
                    STA img_palette_2-1, X
                :
                ; X++
                INC palette_counter+0
                JMP @palette_while
        @palette_while_end:
        
        ; restore header byte
        PLA
    @palette_end:

    ; - - - - - - - -
    ; read tiles
    ; - - - - - - - -
    ; read next header bit
    ASL
    BCC @tiles_end
    @tiles:
        ; save header byte
        PHA
        ;
        LDA img_header
        AND #IMG_HEADER_FULL
        BEQ @tiles_partial
        @tiles_full:
            ; set pointer to tiles background buffer
            sta_ptr tmp+2, IMG_BKG_BUF_LO
            JMP @tile_type_end
        @tiles_partial:
            ; set pointer to tiles character buffer
            sta_ptr tmp+2, IMG_CHR_BUF_LO
        @tile_type_end:
        ; decode tiles
        JSR rleinc
        ; restore header byte
        PLA
    @tiles_end:

    ; - - - - - - - -
    ; read sprites
    ; - - - - - - - -
    ; read next header bit
    ASL
    BCC @sprites_end
    @sprites:
        ; save header byte
        PHA
        ; read sprite header
        JSR rleinc_next
        STA img_spr_w
        JSR rleinc_next
        STA img_spr_b
        JSR rleinc_next
        STA img_spr_x
        JSR rleinc_next
        add #24
        STA img_spr_y
        ; set pointer to sprites background buffer
        sta_ptr tmp+2, IMG_CHR_BUF_SPR
        ; decode sprites
        JSR rleinc
        ; update number of sprites
        mov img_spr_count, tmp+2
        ; clear the character sprite buffer
        TAY
        LDA #$00
        STA tmp+2
        @sprites_empty_rlebuf:
            STA (tmp+2), Y
            INY
            BNE @sprites_empty_rlebuf
        ; restore header byte
        PLA
    @sprites_end:

    ; - - - - - - - -
    ; draw
    ; - - - - - - - -
    LDA img_header
    ASL
    ASL ; dont draw palette here, done in main
    ; tiles
    ASL
    BCC @draw_tiles_end
    @draw_tiles:
        ;
        PHA
        ; do we draw all the tiles or just some ?
        BIT img_header
        BMI @draw_tiles_full
        ; draw tiles
        @draw_tiles_part:
            JSR img_bkg_draw_partial
            JMP @draw_tiles_done
        @draw_tiles_full:
            JSR img_bkg_draw
        @draw_tiles_done:
        ;
        PLA
    @draw_tiles_end:
    ; sprites
    ASL
    BCC @draw_sprites_end
    @draw_sprites:
        ; draw sprites
        JSR img_spr_draw
    @draw_sprites_end:

    @end:
    pullregs
    RTS
