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
    for_y @loop, #0
        LDA (tmp+2), Y
        STA background, X
        INX
    to_y_inc @loop, #$40
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

    JSR img_spr_clear
    ; set bank
    mov MMC5_RAM_BNK, #IMG_BUF_BNK
    ; init pointers
    sta_ptr tmp, (PPU_NAMETABLE_0+$60)
    sta_ptr tmp+2, MMC5_RAM
    sta_ptr tmp+4, (MMC5_EXP_RAM+$60)

    ; - - - - - - - -
    ; copy buffer to screen
    ; - - - - - - - -
    BIT effect_flags
    BMI @dialog_box_off
    @dialog_box_on:
        LDX #8
        JMP @loop
    @dialog_box_off:
        LDX #12
    @loop:
        ; wait for the next frame
        JSR wait_next_frame

        ; draw 2 lines on the PPU nametable
        JSR img_bkg_draw_2lines

        ; change data pointer to high bytes
        LDA tmp+3
        add #03
        STA tmp+3

        ; draw 2 lines on the expansion ram
        LDY #$3F
        @loop_exp:
            ; copy
            LDA (tmp+2), Y
            BIT scanline
            BVC @loop_exp
            STA (tmp+4), Y
            ; continue
            DEY
            BPL @loop_exp

        ; change data pointer to low bytes
        LDA tmp+3
        sub #03
        STA tmp+3

        ; update pointers
        add_A2ptr tmp, #$40
        add_A2ptr tmp+2, #$40
        add_A2ptr tmp+4, #$40

        ; continue
        DEX
        bnz @loop

    pullregs
    RTS
