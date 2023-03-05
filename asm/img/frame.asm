; params:
; X, tmp+2
frame_set_pal:
    pushregs

    ; multiply X by 3
    STX MMC5_MUL_A
    mvx MMC5_MUL_B, #$03
    LDX MMC5_MUL_A
    
    ; move palette
    for_y @loop, #1
        LDA (tmp+2), Y
        STA img_palette_0, X
        INX
        to_y_inc @loop, #4

    pullregs
    RTS


frame_decode:
    pushregs

    ; tmp+2 = anim_adr
    mov_ptr tmp+2, anim_adr

    ; is a fade effect active ?
    LDA fade_timer
    bze :+
        ; then do nothing
        JMP @end
    :
    ; is a fade out effect active ?
    LDA effect_flags
    AND #(EFFECT_FLAG_FADE)
    bnz :+
        ; then do nothing
        JMP @end
    :

    ; is the animation frame counter > 0 ?
    LDA anim_frame_counter
    bze :+
        ; then decrement it and jump to the end
        DEC anim_frame_counter
        JMP @end
    :
    LDA anim_img_counter
    bze @load_bck
    @load_chr:
        ;
        LDY #$00
        LDA (tmp+2), Y
        STA anim_frame_counter
        ;
        INY
        LDA (tmp+2), Y
        STA tmp+0
        INY
        LDA (tmp+2), Y
        STA tmp+1
        ;
        INY
        LDA (tmp+2), Y
        STA mmc5_banks+2
        STA MMC5_PRG_BNK1
        ;
        DEC anim_img_counter
        ;
        INY
        TYA
        add_A2ptr anim_adr
        JMP @start
    @load_bck:
        ;
        LDA anim_base_adr+0
        STA anim_adr+0
        STA tmp+2
        LDA anim_base_adr+1
        STA anim_adr+1
        STA tmp+3
        ;
        LDY #$00
        LDA (tmp+2), Y
        LSR
        LSR
        STA anim_img_counter
        ;
        inc_16 anim_adr

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
    LDA (tmp), Y
    STA img_header
    ; increase pointer
    inc_16 tmp
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

        INY
        LDA (tmp), Y
        ASL
        ASL
        TAX
        LDA palette_table, X
        STA img_palette_bkg
        DEY

        LDX #$00
        @palette_loop:
            ;
            sta_ptr tmp+2, palette_table
            ;
            INY
            LDA (tmp), Y
            ASL
            ASL
            add_A2ptr tmp+2
            ;
            INY
            TYA
            PHA

            JSR frame_set_pal

            PLA
            TAY
            INX
            CPX #$04
            BNE @palette_loop
        
        ; update pointer
        TYA
        LDY #$00
        add_A2ptr tmp
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
        ; set pointer to tiles background buffer
        sta_ptr tmp+2, MMC5_RAM
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
        LDA (tmp), Y
        STA img_spr_w
        INY
        LDA (tmp), Y
        STA img_spr_b
        INY
        LDA (tmp), Y
        STA img_spr_x
        INY
        LDA (tmp), Y
        add #24
        STA img_spr_y
        INY
        ; update pointer
        TYA
        add_A2ptr tmp
        ; set pointer to sprites background buffer
        sta_ptr tmp+2, (MMC5_RAM+$600)
        ;
        LDY #$00
        TYA
        @sprites_empty_rlebuf:
            STA (tmp+2), Y
            DEY
            bnz @sprites_empty_rlebuf
        ; decode sprites
        JSR rleinc
        ; update number of sprites
        mov img_spr_count, tmp+2
        ; restore header byte
        PLA
    @sprites_end:

    ; - - - - - - - -
    ; draw
    ; - - - - - - - -
    LDA img_header
    ASL
    ASL
    BCC @draw_palettes_end
    @draw_palettes:
        ;
        PHA
        ; update palette 0
        mov palettes+0, img_palette_bkg
        mov palettes+1, img_palette_0+0
        mov palettes+2, img_palette_0+1
        mov palettes+3, img_palette_0+2
        ; update palette 1
        mov palettes+4, img_palette_1+0
        mov palettes+5, img_palette_1+1
        mov palettes+6, img_palette_1+2
        ; update palette 2
        mov palettes+7, img_palette_2+0
        mov palettes+8, img_palette_2+1
        mov palettes+9, img_palette_2+2
        ; update palette 3
        mov palettes+13, img_palette_3+0
        mov palettes+14, img_palette_3+1
        mov palettes+15, img_palette_3+2
        ;
        PLA
    @draw_palettes_end:
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
            JMP @draw_tiles_wait
        @draw_tiles_full:
            JSR img_bkg_draw
        @draw_tiles_wait:
        ; wait one frame to clear the nmi background buffer
        JSR wait_next_frame
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
