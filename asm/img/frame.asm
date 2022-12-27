
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
    PHA
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
        ; TODO
        LDA #$08
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
    PLA
    ASL
    ASL
    ; tiles
    ASL
    BCC @draw_tiles_end
    @draw_tiles:
        ;
        PHA
        ; draw tiles
        JSR img_bkg_draw
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
