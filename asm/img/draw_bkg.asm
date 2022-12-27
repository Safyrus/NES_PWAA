; params:
; - tmp+0: ppu adr
; - tmp+2: data ptr
; use: A, X, Y
img_bkg_draw_2lines:
    pushregs

    ; init packet
    LDX background_index
    LDA #$40
    STA background, X
    INX
    LDA tmp+1
    STA background, X
    INX
    LDA tmp+0
    STA background, X
    INX
    ; fill packet
    LDY #$00
    @loop:
        LDA (tmp+2), Y
        STA background, X
        INX
        ; continue
        INY
        CPY #$40
        BNE @loop
    ; close packet
    LDA #$00
    STA background, X
    STX background_index

    pullregs
    RTS

; description:
;   draw the background part of the image
; use tmp[0..5]
img_bkg_draw:
    pushregs

    ; set bank
    LDA #IMG_BUF_BNK
    STA MMC5_RAM_BNK
    ; init pointers
    LDA #<(PPU_NAMETABLE_0+$60)
    STA tmp+0
    LDA #>(PPU_NAMETABLE_0+$60)
    STA tmp+1
    LDA #<MMC5_RAM
    STA tmp+2
    LDA #>MMC5_RAM
    STA tmp+3
    LDA #<(MMC5_EXP_RAM+$60)
    STA tmp+4
    LDA #>(MMC5_EXP_RAM+$60)
    STA tmp+5

    ; - - - - - - - -
    ; copy buffer to screen
    ; - - - - - - - -
    LDX #12
    @loop:
        ; wait for the next frame
        JSR wait_next_frame

        ; draw 2 lines on the PPU nametable
        JSR img_bkg_draw_2lines

        ; change data pointer to high bytes
        LDA tmp+3
        CLC
        ADC #03
        STA tmp+3

        ; draw 2 lines on the expansion ram
        LDY #$3F
        @loop_exp:
            ; copy
            LDA (tmp+2), Y
            STA (tmp+4), Y
            ; continue
            DEY
            BPL @loop_exp

        ; change data pointer to low bytes
        LDA tmp+3
        SEC
        SBC #03
        STA tmp+3

        ; update pointers
        LDA #$40
        add_A2ptr tmp
        LDA #$40
        add_A2ptr tmp+2
        LDA #$40
        add_A2ptr tmp+4

        ; continue
        DEX
        BNE @loop

    pullregs
    RTS
