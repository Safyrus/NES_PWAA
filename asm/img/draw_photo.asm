; X,Y = ppu address (lo, hi)
draw_photo:
    ; - - - - - - - - - -
    ; Setup
    ; - - - - - - - - - -
    ; push bank at $A000-$BFFF
    LDA mmc5_banks+2
    PHA
    ; set $A000-$BFFF to EVI_BNK
    LDA #EVI_BNK
    STA mmc5_banks+2
    STA MMC5_PRG_BNK1

    ; push tmp 0-3
    push tmp+0
    push tmp+1
    push tmp+2
    push tmp+3

    ; push X,Y
    TXA
    PHA
    TYA
    PHA

    ; tmp = evi_imgs
    sta_ptr tmp, evi_imgs


    ; - - - - - - - - - -
    ; Find photo data
    ; - - - - - - - - - -
    LDY #$00
    ; X = img_photo & $7F (clear draw flag)
    LDA img_photo
    AND #$7F
    TAX
    @while_find:
        BEQ @while_find_end
        ; size = len(photo[X])
        LDA (tmp), Y
        ; tmp += size
        add_A2ptr tmp
        ; continue
        DEX
        JMP @while_find
    @while_find_end:


    ; - - - - - - - - - -
    ; Decode photo
    ; - - - - - - - - - -
    ; ; palette[0]
    ; INY
    ; LDA (tmp), Y
    ; STA evi_palette+0
    ; ; palette[1]
    ; INY
    ; LDA (tmp), Y
    ; STA evi_palette+1
    ; ; palette[2]
    ; INY
    ; LDA (tmp), Y
    ; STA evi_palette+2
    ; tmp += 4
    ; INY
    ; TYA
    ; add_A2ptr tmp
    ; tmp++
    inc_16 tmp
    ; output pointer
    sta_ptr tmp+2, buf_photo_lo
    ; rleinc for low bytes
    JSR rleinc
    ; rleinc for high bytes
    JSR rleinc


    ; - - - - - - - - - -
    ; Draw photo
    ; - - - - - - - - - -
    ; tmp = pull X,Y
    PLA
    STA tmp+1
    PLA
    STA tmp+0

    ; wait for ppu buffer to be empty
    JSR wait_next_frame
    ; draw top 4 lines
    LDY #$00
    JSR draw_photo_1line
    JSR draw_photo_1line
    JSR draw_photo_1line
    JSR draw_photo_1line
    ; wait for ppu buffer to be empty again
    JSR wait_next_frame
    ; draw bot 4 lines
    JSR draw_photo_1line
    JSR draw_photo_1line
    JSR draw_photo_1line
    JSR draw_photo_1line

    ; tmp = MMC5_EXP_RAM + (tmp & $03FF) - $100
    DEC tmp+1
    LDA tmp+1
    AND #$03
    add #>MMC5_EXP_RAM
    STA tmp+1
    ; draw upper tiles
    LDY #$00
    for_x @exp, #8
        @1line:
            ; tmp[y] = buf_photo_hi[y]
            LDA buf_photo_hi, Y
            STA (tmp), Y
            ; while y & 7 != 0
            INY
            TYA
            AND #$07
            BNE @1line
        add_A2ptr tmp, #$18
    to_x_dec @exp, #0

    ; - - - - - - - - - -
    ; Clean
    ; - - - - - - - - - -

    ; pull tmp 0-3
    pull tmp+3
    pull tmp+2
    pull tmp+1
    pull tmp+0
    ; pull bank
    PLA
    STA mmc5_banks+2
    STA MMC5_PRG_BNK1

    ; return
    RTS


; Y = offset in buf_photo_lo
; tmp = ppu address
draw_photo_1line:
    ; init packet
    LDX background_index
    LDA #$08
    STA background, X
    INX
    LDA tmp+1
    STA background, X
    INX
    LDA tmp+0
    STA background, X
    INX
    ; for y+0 to y+7
    @loop:
        ; send 1 byte
        LDA buf_photo_lo, Y
        STA background, X
        INX
        ; while y & 7 != 0
        INY
        TYA
        AND #$07
        BNE @loop

    ; close packet
    LDA #$00
    STA background, X
    STX background_index
    ; tmp += 32
    add_A2ptr tmp, #$20
    ; return
    RTS
