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

    ; set bank
    mov MMC5_RAM_BNK, #IMG_BUF_BNK
    STA mmc5_banks+0
    ; init pointers
    sta_ptr tmp, (PPU_NAMETABLE_0+$60)
    sta_ptr tmp+2, MMC5_RAM
    ;
    LDA effect_flags
    AND #EFFECT_FLAG_DRAW
    BNE @flip_nt_end
        ; flip the nametable to use and set the EFFECT_FLAG_DRAW flag
        LDA effect_flags
        EOR #EFFECT_FLAG_NT
        ORA #EFFECT_FLAG_DRAW
        STA effect_flags
    @flip_nt_end:
    ; and offset the ppu pointer if needed
    LDA effect_flags
    AND #EFFECT_FLAG_NT
    ORA tmp+1
    STA tmp+1

    ; - - - - - - - -
    ; copy buffer to screen
    ; - - - - - - - -
    ; find how many loop we need to do
    BIT effect_flags
    BMI @dialog_box_off
    @dialog_box_on:
        LDX #8
        JMP @loop
    @dialog_box_off:
        LDX #12
    ; start the loop
    @loop:
        ; wait for the next frame
        JSR wait_next_frame

        ; draw 2 lines on the PPU nametable
        JSR img_bkg_draw_2lines

        ; update pointers
        add_A2ptr tmp, #$40
        add_A2ptr tmp+2, #$40

        ; continue
        DEX
        bnz @loop


    ; skip MMC5 update if any character is currently drawn
    ora_adr effect_flags, #EFFECT_FLAG_BKG_MMC5 ; pre-enable flag
    LDA img_character
    BNE @end
    LDA img_animation
    BNE @end
        ;
        sta_ptr tmp, (MMC5_RAM+$900)
        JSR cp_2_mmc5_exp
        ;
        and_adr effect_flags, #($FF-EFFECT_FLAG_BKG_MMC5) ; reset the flag
        ; clear the EFFECT_FLAG_DRAW flag
        and_adr effect_flags, #($FF - EFFECT_FLAG_DRAW)
        ;
        JSR update_screen_scroll

    @end:
    pullregs
    RTS
