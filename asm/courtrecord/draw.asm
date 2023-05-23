update_court_record_box:
    ; if the court record show flag is set
    LDA cr_flag
    AND #CR_FLAG_SHOW
    BEQ :+
        ; then draw the box
        JMP draw_court_record_box
    :
        ; else undraw the box
        JMP undraw_court_record_box

draw_court_record_box:
    pushregs

    ; wait for the start of the frame
    @wait_start:
        BIT scanline
        BVC @wait_start
    ; and acknowledge NMI
    JSR wait_next_frame

    ; - - - - - - - -
    ; frame 1 (top line)
    ; - - - - - - - -
    sta_ptr tmp, (PPU_NAMETABLE_0+$E0)
    LDA #BOX_TILE_TL
    JSR _draw_dialog_box_line

    ; - - - - - - - -
    ; frame 1 (bot line)
    ; - - - - - - - -
    sta_ptr tmp, (PPU_NAMETABLE_0+$1C0)
    LDA #BOX_TILE_BL
    JSR _draw_dialog_box_line

    ; - - - - - - - -
    ; frame 2, to 7
    ; - - - - - - - -
    ; tmp = ppu adr
    sta_ptr tmp, (PPU_NAMETABLE_0 + $100)
    ; draw each line
    mov tmp+2, #$03
    @loop_frames:
        JSR wait_next_frame

        ; draw one line
        LDA #BOX_TILE_L
        JSR _draw_dialog_box_line
        ; tmp += $20
        add_A2ptr tmp, #$20
        ; draw another line
        LDA #BOX_TILE_L
        JSR _draw_dialog_box_line
        ; tmp += $20
        add_A2ptr tmp, #$20

        ; next
        DEC tmp+2
        bnz @loop_frames

    JSR wait_next_frame
    ; wait to be in frame
    @wait_inframe:
        BIT scanline
        BVC @wait_inframe
    ; set ptr to ext ram
    sta_ptr tmp, (MMC5_EXP_RAM+$E0)
    ; set ext ram
    LDA #(BOX_UPPER_TILE & $3F + $C0)
    for_y @loop_ext, #0
        STA (tmp), Y
    to_y_inc @loop_ext, #0

    pullregs
    RTS

undraw_court_record_box:
    PHA

    sta_ptr tmp+0, (PPU_NAMETABLE_0+$E0)
    JSR img_draw_mid_lo
    sta_ptr tmp+0, (MMC5_EXP_RAM+$E0)
    JSR img_draw_mid_hi

    PLA
    RTS



; tmp = ppu address
img_draw_mid_lo:
    ; push registers
    pushregs

    ; copy lower tiles
    LDY #$00
    @loop:
        ; wait for the next frame
        JSR wait_next_frame
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
        @data:
            ; if CHR_PTR_HI[y] = 0
            LDA IMG_CHR_BUF_HI+$80, Y
            BNE @chr
            @bkg:
                ; then tile = BKG_PTR[y]
                LDA IMG_BKG_BUF_LO+$80, Y
                JMP @send
            @chr:
                LDA IMG_CHR_BUF_LO+$80, Y
                ; else tile = CHR_PTR[y]
            @send:
            ; PPU_PTR[y] = tile
            STA background, X
            INX
            ; y++
            INY
            ; if y % 64 = 0 then break
            TYA
            AND #$3F
            BNE @data
        ; close packet
        LDA #$00
        STA background, X
        STX background_index
        ; ppu_ptr += $40
        add_A2ptr tmp+0, #$40
        ; if y = 0 then break
        CPY #$00
        BNE @loop

    pullregs
    RTS

; /!\ need to be in-frame
; tmp+0 = exp pointer
img_draw_mid_hi:
    PHA

    ; copy upper tiles
    ; for y from 0 to 255
    for_y @loop, #0
        ; if CHR_PTR[y] = 0
        LDA IMG_CHR_BUF_HI+$80, Y
        BNE @chr
        @bkg:
            ; then tile = BKG_PTR[y]
            LDA IMG_BKG_BUF_HI+$80, Y
        @chr:
            ; else tile = CHR_PTR[y]
        ; EXP_PTR[y] = tile
        STA (tmp+0), Y
    to_y_inc @loop, #0    

    PLA
    RTS
