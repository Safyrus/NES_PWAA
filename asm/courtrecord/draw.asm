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


    push txt_rd_ptr+0
    push txt_rd_ptr+1
    push print_ext_ptr+0
    push print_ext_ptr+1
    push print_ppu_ptr+0
    push print_ppu_ptr+1
    push print_nl_offset

    sta_ptr print_ext_ptr, (MMC5_EXP_RAM+$109)
    sta_ptr print_ppu_ptr, (PPU_NAMETABLE_0+$109)
    mov print_nl_offset, #$29

    LDX cr_idx
    LDA table_evidence_top_lo, X
    STA txt_rd_ptr+0
    LDA table_evidence_top_hi, X
    STA txt_rd_ptr+1

    ; read top choice text
    LDY #$00
    @while_top:
        ;
        LDA (txt_rd_ptr), Y
        inc_16 txt_rd_ptr
        ;
        JSR print_char
        ;
        CMP #$02
        BEQ @while_top_end
        CMP #$01
        BNE @while_top
        JSR print_flush_wait
        JSR print_lb_noflush
        JMP @while_top
    @while_top_end:
    JSR print_flush_wait
    JSR print_lb_noflush

    pull print_nl_offset

    push name_idx
    mov name_idx, #$00

    ; draw photo
    LDX cr_idx
    LDA table_cr2photo, X
    STA img_photo
    LDY #$20
    LDX #$E0
    JSR draw_photo

    JSR draw_dialog_box

    pull name_idx

    sta_ptr print_ext_ptr, (MMC5_EXP_RAM+$282)
    sta_ptr print_ppu_ptr, (PPU_NAMETABLE_0+$282)

    LDX cr_idx
    LDA table_evidence_bot_lo, X
    STA txt_rd_ptr+0
    LDA table_evidence_bot_hi, X
    STA txt_rd_ptr+1

    ; read bottom choice text
    LDY #$00
    @while_bot:
        ;
        LDA (txt_rd_ptr), Y
        inc_16 txt_rd_ptr
        ;
        JSR print_char
        ;
        CMP #$02
        BEQ @while_bot_end
        CMP #$01
        BNE @while_bot
        JSR print_flush_wait
        JSR print_lb_noflush
        JMP @while_bot
    @while_bot_end:
    JSR print_flush_wait
    JSR print_lb_noflush

    pull print_ppu_ptr+1
    pull print_ppu_ptr+0
    pull print_ext_ptr+1
    pull print_ext_ptr+0
    pull txt_rd_ptr+1
    pull txt_rd_ptr+0

    pullregs
    RTS

undraw_court_record_box:
    PHA

    sta_ptr tmp+0, (PPU_NAMETABLE_0+$E0)
    JSR img_draw_mid_lo
    sta_ptr tmp+0, (MMC5_EXP_RAM+$E0)
    JSR img_draw_mid_hi

    ; restore text pointer
    mov txt_rd_ptr+0, txt_last_dialog_adr+0
    mov txt_rd_ptr+1, txt_last_dialog_adr+1
    ; restore text bank
    LDX txt_last_dialog_adr+2
    CPX lz_idx
    STX lz_idx
    ; if it is not the same as now then lz
    BNE @lz
    ; if text bank not the same
    LDA lz_bnk_table, X
    CMP lz_in_bnk
    BEQ @undraw
    @lz:
        ; reset lz decoding
        JSR lz_init
        ; async lz_decode()
        ora_adr txt_flags, #TXT_FLAG_LZ
    @undraw:
    ; redraw dialog box
    ora_adr txt_flags, #(TXT_FLAG_FORCE)
    JSR draw_dialog_box

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
