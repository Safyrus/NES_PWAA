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
    ; flip the nametable to use and set the EFFECT_FLAG_DRAW flag
    LDA effect_flags
    EOR #EFFECT_FLAG_NT
    ORA #EFFECT_FLAG_DRAW
    STA effect_flags
    AND #EFFECT_FLAG_NT
    ; and offset the ppu pointer if needed
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


    ; - - - - - - - -
    ; copy exp buffer to expansion ram
    ; - - - - - - - -
    ; init pointers
    sta_ptr tmp, (MMC5_EXP_RAM+$60)
    sta_ptr tmp+2, (MMC5_RAM+$300)
    ; find how many loop we need to do
    LDX #3
    BIT effect_flags
    BMI @exp_dialog_box_off
        ; X = 2
        DEX
    @exp_dialog_box_off:
        ; X = 3
    ; start the loop
    @loop_exp:
        ; no need to check if we are still in frame
        ; because we now that we are at the top of the frame
        for_y @loop_exp_page, #0
            ; load and store the next byte
            LDA (tmp+2), Y
            STA (tmp), Y
        to_y_inc @loop_exp_page, #0
        ; update pointers
        INC tmp+1
        INC tmp+3
    to_x_dec @loop_exp, #0

    ; clear the EFFECT_FLAG_DRAW flag
    and_adr effect_flags, #($FF - EFFECT_FLAG_DRAW)
    JSR update_screen_scroll

    pullregs
    RTS
