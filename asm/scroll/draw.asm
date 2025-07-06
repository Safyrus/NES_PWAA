; A = nb_pixel
scroll_draw:
    @adr = tmp+0
    @packet = tmp+2
    @tile_lo = tmp+4
    @tile_hi = tmp+6
    @packet_idx = tmp+8
    @size = tmp+9
    @adr_step = tmp+10
    @n = tmp+11
    @cur_img = @adr+1
    @tmp_adr = @packet

    ; n = A >> 3
    LSR
    LSR
    LSR
    STA @n
    ; set bank
    push mmc5_banks+2
    mov mmc5_banks+2, #GENERAL_BNK
    STA MMC5_PRG_BNK1

    ; for n
    @for:
        ; if direction vertical
        LDA scroll_dir
        AND #$02
        BEQ @else
            ; line_size = $20
            mov @size, #$20
            ; adr_step = 1
            mov @adr_step, #1
            ; cur_img = tile_offset / 24
            mov @cur_img, #$00
            LDA tile_offset
            :
            CMP #24
            blt :+
                sub #24
                INC @cur_img
                JMP :-
            :
            JMP @fi
        ; else
        @else:
            ; line_size = $18 + vertical
            mov @size, #$98
            ; adr_step = 32
            mov @adr_step, #32
            ; cur_img = tile_offset / 32
            LDA tile_offset
            LSR
            LSR
            LSR
            LSR
            LSR
            STA @cur_img
        @fi:

        ; adr = cur_img * 256 * 3
        mov @adr+0, #$00
        LDA @cur_img
        STA MMC5_MUL_A
        LDA #$03
        STA MMC5_MUL_B
        LDA MMC5_MUL_A
        STA @adr+1

        ; if direction up
        LDA scroll_dir
        CMP #SCROLL_DIR_UP
        BNE :++
            ; adr += 256 * 3
            LDA @adr+1
            add #$03
            STA @adr+1
            ; A = (tile_offset % 24) + 1
            LDA tile_offset
            AND #$1F
            CMP #23
            blt :+
                sub #24
            :
            add #$01
            ; tmp_adr = A * 32
            STA @tmp_adr+0
            LSR
            LSR
            LSR
            STA @tmp_adr+1
            LDA @tmp_adr+0
            ASL
            ASL
            ASL
            ASL
            ASL
            STA @tmp_adr+0
            ; adr -= tmp_adr
            ; break
            LDA @adr+1
            sub @tmp_adr+1
            STA @adr+1
            LDA @adr+0
            sub @tmp_adr+0
            STA @adr+0
            BCS @break
            DEC @adr+1
            JMP @break
        :
        ; if direction down
        CMP #SCROLL_DIR_DOWN
        BNE :++
            ; adr += (tile_offset % 24) * 32
            LDA tile_offset
            AND #$1F
            CMP #23
            blt :+
                sub #24
            :
            STA @adr+0
            LSR
            LSR
            LSR
            add @adr+1
            STA @adr+1
            LDA @adr+0
            ASL
            ASL
            ASL
            ASL
            ASL
            STA @adr+0
            ; break
            JMP @break
        :
        ; if direction left
        CMP #SCROLL_DIR_LEFT
        BNE :+
            ; adr += 31 - (tile_offset % 32)
            LDA tile_offset
            AND #$1F
            EOR #$1F
            add_A2ptr @adr
            ; break
            JMP @break
        :
        ; if direction right
            ; adr += tile_offset % 32
            LDA tile_offset
            AND #$1F
            add_A2ptr @adr
            ; break
        @break:

        ; tile_lo = scroll_img_buffers_lo[adr]
        ; tile_hi = scroll_img_buffers_hi[adr]
        LDA @adr+0
        STA @tile_lo+0
        STA @tile_hi+0
        LDA @adr+1
        add #>SCROLL_IMG_BUFFERS_LO+$40
        STA @tile_lo+1
        LDA @adr+1
        add #>SCROLL_IMG_BUFFERS_HI+$40
        STA @tile_hi+1

        ; ppu_adr = scroll_ppu_adr
        mov @adr+0, scroll_ppu_adr+0
        mov @adr+1, scroll_ppu_adr+1
        ; scroll_step_ppu()
        JSR scroll_step_ppu

        ; packet = packet_buf_res(line_size, ppu_adr)
        LDY @size
        JSR packet_buf_res
        INY
        STY @packet_idx
        ; for line_size
        LDA @size
        AND #$7F
        TAX
        @for_packet:
            ; *packet = *tile_lo
            ; packet++
            LDY #$00
            LDA (@tile_lo), Y
            LDY @packet_idx
            STA (@packet), Y
            INC @packet_idx
            ; *packet = *tile_hi with scroll_pal_flip
            ; packet++
            LDY #$00
            LDA (@tile_hi), Y
            AND #$7F
            ORA scroll_pal_flip
            LDY @packet_idx
            STA (@packet), Y
            INC @packet_idx
            ; tile_lo += adr_step
            ; tile_hi += adr_step
            add_A2ptr @tile_lo, @adr_step
            add_A2ptr @tile_hi, @adr_step
            ; continue
            DEX
            BNE @for_packet
        ; close_packet(line_size)
        LDA @size
        JSR close_packet
        ; tile_offset++
        INC tile_offset
        ; continue
        DEC @n
        BEQ @ret
        JMP @for

    ; return
    @ret:
    ; restore bank
    pull mmc5_banks+2
    STA MMC5_PRG_BNK1
    RTS


scroll_tile_offset_to_ppu_adr:
    @adr = tmp+0

    ; switch(direction)
    LDA scroll_dir
    ; case UP:
    CMP #SCROLL_DIR_UP
    BNE :++++
        ; offset = (2-tile_offset) % 60
        LDA #$02
        sub tile_offset
        @set_adr_ver:
        :
        CMP #60
        blt :+
        sub #60
        JMP :-
        :
        ; if offset >= 30
        CMP #30
        blt :+
            ; ppu_adr = $2800 + ((offset-30)*$20)
            sub #30
            JSR a_time_32
            LDA #$28
            ORA @adr+1
            STA @adr+1
            ; return
            RTS
        ; else
        :
            ; ppu_adr = $2000 + (offset*$20)
            JSR a_time_32
            LDA #$20
            ORA @adr+1
            STA @adr+1
            ; return
            RTS
    :
    ; case DOWN:
    CMP #SCROLL_DIR_DOWN
    BNE :+
        ; offset = (tile_offset+27) % 60
        LDA tile_offset
        add #27
        ; goto set_adr_ver
        JMP @set_adr_ver
    :
    ; case LEFT:
    CMP #SCROLL_DIR_LEFT
    BNE :++
        ; offset = (-(tile_offset+1)) & $3F
        LDA #$FF
        sub tile_offset
        @set_adr_hor:
        AND #$3F
        ; if offset >= $20
        CMP #$20
        blt :+
            ; ppu_adr = $2460 + (offset-$20)
            add #$40
            STA @adr+0
            LDA #$24
            STA @adr+1
            ; return
            RTS
        ; else
        :
            ; ppu_adr = $2060 + offset
            add #$60
            STA @adr+0
            LDA #$20
            STA @adr+1
            ; return
            RTS
    :
    ; case RIGHT:
    CMP #SCROLL_DIR_RIGHT
    BNE :+
        ; offset = (tile_offset+$20) & $3F
        LDA tile_offset
        add #$20
        ; goto set_adr_hor
        JMP @set_adr_hor
    :

    ; error
    BRK


a_time_32:
    @adr = tmp+0
    PHA
    ASL
    ASL
    ASL
    ASL
    ASL
    STA @adr+0
    PLA
    LSR
    LSR
    LSR
    STA @adr+1
    RTS
