img_bkg_draw_partial:
    pushregs

    ; set bank
    mov MMC5_RAM_BNK, #IMG_BUF_BNK
    STA mmc5_banks+0

    ; init data pointer
    sta_ptr tmp, IMG_CHR_BUF_LO
    sta_ptr tmp+4, IMG_CHR_BUF_HI
    sta_ptr tmp+10, (MMC5_EXP_RAM+$60)
    sta_ptr tmp+8, IMG_BKG_BUF_HI

    ; enable NMI_FORCE flag
    ora_adr nmi_flags, #NMI_FORCE

    ;
    JSR img_partial_ppuadr

    LDA #$62
    STA tmp+12
    BIT box_flags
    BPL :+
        INC tmp+12
    :

    ; while not end of buffer
    @while_ppu:
        ; get next byte
        LDA (tmp+4), Y
        ; if byte = 0, then flush buffer
        BNE @draw
        @flush:
            ; if EFFECT_FLAG_BKG_MMC5 is set
            LDA effect_flags
            AND #EFFECT_FLAG_BKG_MMC5
            BEQ :++
                ; wait_inframe
                :
                    BIT scanline
                    BVC :-
                ; copy background tile to MMC5
                LDA (tmp+8), Y
                STA (tmp+10), Y
            :
            ; 
            inc_16 tmp
            ; flush buffer (and skip the low tile)
            JSR img_partial_buf_flush
            JSR img_partial_ppuadr
            JMP @continue
        @draw:
            ; wait in frame
            :
                BIT scanline
                BVC :-
            ; copy character tile to MMC5
            LDA (tmp+4), Y
            STA (tmp+10), Y
            ;
            LDA (tmp), Y
            inc_16 tmp
            ; else draw the low tile
            JSR img_partial_buf_draw
        @continue:
        ; increase pointers
        inc_16 tmp+4
        inc_16 tmp+10
        inc_16 tmp+8
        ; wild code to check if the loop is finished
        ; depending on if the dialog box is active or not
        LDA tmp+1
        CMP tmp+12
        BNE @while_ppu
    @while_ppu_end:
    JSR img_partial_buf_flush


    ;
    @wait_next_frame:
        LDA scanline
        CMP #SCANLINE_TOP_IMG
        BNE @wait_next_frame

    JSR update_screen_scroll
    ; disable NMI_FORCE flag
    and_adr nmi_flags, #($FF-NMI_FORCE)
    ; clear the EFFECT_FLAG_DRAW flag
    and_adr effect_flags, #($FF - EFFECT_FLAG_DRAW)
    ; clear the EFFECT_FLAG_BKG_MMC5 flag
    and_adr effect_flags, #($FF-EFFECT_FLAG_BKG_MMC5)

    @end:
    pullregs
    RTS


img_partial_ppuadr:
    PHA

    LDA tmp+0
    STA tmp+2
    LDA tmp+1
    AND #$03
    ORA #$20
    STA tmp+3
    ; offset by 1 nametable if needed
    LDA effect_flags
    AND #EFFECT_FLAG_NT
    ORA tmp+3
    STA tmp+3
    ; offset of 24 scanlines
    add_A2ptr tmp+2, #$60

    PLA
    RTS

; param: A
; use: X
img_partial_buf_draw:
    ; if img_partial_buf_len >= IMG_PARTIAL_MAX_BUF_LEN
    LDX img_partial_buf_len
    CPX #IMG_PARTIAL_MAX_BUF_LEN
    blt :+
        ; img_partial_buf_flush()
        JSR img_partial_buf_flush
        LDX img_partial_buf_len
    :
    ; img_partial_buf = A
    STA img_partial_buf, X
    ; img_partial_buf++
    INX
    STX img_partial_buf_len
    RTS

img_partial_buf_flush:
    pushregs

    ; if buffer empty, then end
    LDA img_partial_buf_len
    bze @end
    ; wait for nmi tile buffer to empty out if it is too big
    @wait_vblank:
        LDA img_partial_buf_len
        add background_index
        CMP #$41
        bge @wait_vblank
    and_adr nmi_flags, #($FF-NMI_DONE) ; fix nmi not doing anything because we wait too many frames
    ; don't draw at the end of a frame (no time to close the packet)
    @wait_inframe:
        BIT scanline
        BVC @wait_inframe
    ; send buffer size
    LDX background_index
    LDA img_partial_buf_len
    STA background, X
    INX

    ; send ppu adr
    LDA tmp+3
    STA background, X
    INX
    LDA tmp+2
    STA background, X
    INX

    ; send buffer
    LDY #$00
    @loop:
        ;
        LDA img_partial_buf, Y
        STA background, X
        INX
        ; continue
        INY
        CPY img_partial_buf_len
        BNE @loop

    ; close packet
    LDA #$00
    STA background, X
    STX background_index
    ; reset buffer
    STA img_partial_buf_len

    @end:
    pullregs
    RTS

