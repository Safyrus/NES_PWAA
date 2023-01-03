; params:
; X
frame_set_pal:
    pushregs

    STX MMC5_MUL_A
    LDX #$03
    STX MMC5_MUL_B
    LDX MMC5_MUL_A
    
    LDY #$01
    @loop:
        LDA (tmp+2), Y
        STA img_palette_0, X
        INX
        INY
        CPY #$04
        BNE @loop

    pullregs
    RTS


; params:
frame_decode:
    pushregs

    ; set ram bank
    LDA #IMG_BUF_BNK
    STA MMC5_RAM_BNK

    ; Set pointer to image.
    ;  We only need to set it 1 time,
    ;  because the rleinc decode subroutine
    ;  will increase the pointer to the
    ;  end of the rleinc block.
    LDA #<img_data
    STA tmp+0
    LDA #>img_data
    STA tmp+1

    ; - - - - - - - -
    ; read header byte
    ; - - - - - - - -
    LDY #$00
    LDA (tmp), Y
    STA img_header
    ; increase pointer
    inc_16 tmp
    ; TODO: partial frame
    ASL
    ; TODO: CHR upper bits

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
            LDA #<palette_table
            STA tmp+2
            LDA #>palette_table
            STA tmp+3
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
        LDA #<MMC5_RAM
        STA tmp+2
        LDA #>MMC5_RAM
        STA tmp+3
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
        CLC
        ADC #24
        STA img_spr_y
        INY
        ; update pointer
        TYA
        LDY #$00
        add_A2ptr tmp
        ; set pointer to sprites background buffer
        LDA #<(MMC5_RAM+$600)
        STA tmp+2
        LDA #>(MMC5_RAM+$600)
        STA tmp+3
        ; decode sprites
        JSR rleinc
        ; update number of sprites
        LDA tmp+2
        STA img_spr_count
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
        LDA img_palette_bkg
        STA palettes+0
        LDA img_palette_0+0
        STA palettes+1
        LDA img_palette_0+1
        STA palettes+2
        LDA img_palette_0+2
        STA palettes+3
        ; update palette 1
        LDA img_palette_1+0
        STA palettes+4
        LDA img_palette_1+1
        STA palettes+5
        LDA img_palette_1+2
        STA palettes+6
        ; update palette 2
        LDA img_palette_2+0
        STA palettes+7
        LDA img_palette_2+1
        STA palettes+8
        LDA img_palette_2+2
        STA palettes+9
        ; update palette 3
        LDA img_palette_3+0
        STA palettes+13
        LDA img_palette_3+1
        STA palettes+14
        LDA img_palette_3+2
        STA palettes+15
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
        BVS @draw_tiles_full
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


img_bkg_draw_partial:
    RTS
