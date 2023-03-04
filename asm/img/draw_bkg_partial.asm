img_bkg_draw_partial:
    pushregs

    ; set bank
    mov MMC5_RAM_BNK, #IMG_BUF_BNK

    ; init data pointer
    sta_ptr tmp, MMC5_RAM

    ; enable NMI_FORCE flag
    ora_adr nmi_flags, #NMI_FORCE

    ;
    JSR img_partial_ppuadr

    ; while not end of buffer
    @while_ppu:
        ; get next byte
        LDA (tmp), Y
        inc_16 tmp
        ; if byte = 0, then flush buffer
        CMP #$00
        BEQ @flush
        @draw:
            JSR img_partial_buf_draw
            JMP @continue
        @flush:
            JSR img_partial_buf_flush
            JSR img_partial_ppuadr
        @continue:
        LDA tmp+1
        BIT effect_flags
        BMI @ppu_dialog_off
        @ppu_dialog_on:
        CMP #$62
        BNE @while_ppu
        JMP @while_ppu_end
        @ppu_dialog_off:
        CMP #$63
        BNE @while_ppu
    @while_ppu_end:
    JSR img_partial_buf_flush

    ;
    sta_ptr tmp, (MMC5_RAM+$300)
    ; init pointer to exp ram
    sta_ptr tmp+2, (MMC5_EXP_RAM+$60)

    ; copy high bytes to exp ram
    LDY #$00
    @while_ext:
        LDA (tmp), Y
        bze @continue_ext
            BIT scanline
            BVC @while_ext
                STA (tmp+2), Y
        @continue_ext:
        inc_16 tmp
        inc_16 tmp+2
        ;
        LDA tmp+1
        BIT effect_flags
        BMI @ext_dialog_off
        @ext_dialog_on:
        CMP #$65
        BNE @while_ext
        JMP @while_ext_end
        @ext_dialog_off:
        CMP #$66
        BNE @while_ext
    @while_ext_end:

    ; disable NMI_FORCE flag
    and_adr nmi_flags, #($FF-NMI_FORCE)

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
    ; offset of 24 pixels
    add_A2ptr tmp+2, #$60

    PLA
    RTS

; param: A
; use: X
img_partial_buf_draw:
    LDX img_partial_buf_len
    CPX #IMG_PARTIAL_MAX_BUF_LEN
    blt @do
        JSR img_partial_buf_flush
        LDX img_partial_buf_len
    @do:
    STA img_partial_buf, X
    INX
    STX img_partial_buf_len
    RTS

img_partial_buf_flush:
    pushregs

    ; if buffer empty, then end
    LDA img_partial_buf_len
    bze @end
    ; wait for nmi tile buffer to empty out if it is too big
    add background_index
    CMP #$40
    blt @init
    @wait_vblank:
        PHA
        @wait_vblank_loop:
            LDA background_index
            bnz @wait_vblank_loop
        PLA
    @init:
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

