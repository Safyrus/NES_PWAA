; packet structure:
; byte 1:
;   vrssssss
;   ||++++++-- size (nb of 16bit tiles in packet)
;   |+-------- ready
;   +--------- vertical
; byte 2:
;   pm..aaaa
;   ||  ++++-- ppu address (high) (relative to start of first nametable)
;   |+-------- don't draw mmc5 tiles
;   +--------- high priority packet
; byte 3: ppu address (low)
; rest: 2 bytes tile with ppu tile first and mmc5 tile second

draw_packets:
    ; --------
    ; variables
    ; --------
    @in = draw_packet_zpvar+0
    @adr = draw_packet_zpvar+2
    @adr_lo = @adr+0
    @adr_hi = @adr+1
    @cur_prio = draw_packet_var+0
    @zp_bkg_size = draw_packet_var+1
    @can_move_read = draw_packet_var+2
    @dont_draw_mmc5 = draw_packet_var+3
    @size = draw_packet_var+4
    @i = draw_packet_var+5
    @v = draw_packet_var+6

    ; --------
    ; init
    ; --------
    ; zp_bkg_size = ZP_BACKGROUND_SIZE-1 - background_index
    LDA #ZP_BACKGROUND_SIZE-1
    sub background_index
    STA @zp_bkg_size
    ; can_move_read = true
    STA @can_move_read
    ; in = packet_buf_read_adr
    LDA packet_buf_read_adr+0
    STA @in+0
    LDA packet_buf_read_adr+1
    STA @in+1

    LDY #$00
    @while:
        ; --------
        ; while conditions
        ; --------
        ; if zp_bkg_size < 4
        LDA @zp_bkg_size
        CMP #$04
        bge :+
            ; return
            JMP @return
        :
        @search:
        ; if take too long
        LDA scanline
        CMP packet_max_scanline
        BNE :+
            ; return
            JMP @return
        :
        ; if @in == packet_buf_write_adr
        LDA @in+1
        CMP packet_buf_write_adr+1
        BNE :+
        LDA @in+0
        CMP packet_buf_write_adr+0
        BNE :+
            ; return
            JMP @return
        :

        ; --------
        ; find packet
        ; --------
        ; if @in[0] == 0
        LDA (@in), Y
        BNE :++
            ; @in++
            JSR @inc_in_no_z
            ; if can_move_read
            LDA @can_move_read
            BEQ @search
                ; packet_buf_read_adr++
                INC packet_buf_read_adr+0
                BNE :+
                    LDA packet_buf_read_adr+1
                    add #$01
                    AND #>(PACKET_BUFFER_ADR+$3FF)
                    STA packet_buf_read_adr+1
                :
            ; jmp @search
            JMP @search
        :

        ; --------
        ; check packet
        ; --------
        ; size, i = @in[0] & $3F
        LDA (@in), Y
        AND #$3F
        STA @size
        BNE :+
            ; Error: packet of size 0 not valid
            BRK
            .byte $00
        :
        STA @i
        add #$03
        ; if size > zp_bkg_size
        CMP @zp_bkg_size
            ; can_move_read = 0
            ; jmp @continue
            BEQ :+
            BCS @skip_packet
            :
        ; v = @in[0] & $80
        LDA (@in), Y
        AND #$80
        STA @v
        ; dont_draw_mmc5 = @in[1] & $40
        INY
        LDA (@in), Y
        AND #$40
        STA @dont_draw_mmc5
        ; prio = @in[1] & $80
        LDA (@in), Y
        DEY
        AND #$80
        ; if prio != current prio
        CMP @cur_prio
            ; can_move_read = 0
            ; jmp @continue
            BNE @skip_packet
        ; notready = @in[0] & $40
        LDA (@in), Y
        AND #$40
        ; if notready
        BEQ :+
            @skip_packet:
            ; can_move_read = 0
            LDA #$00
            STA @can_move_read
            ; jmp @continue
            JMP @continue
        :

        ; --------
        ; copy packet info
        ; --------
        ; background[background_index] = @in[0] & $BF ; remove notready flag
        LDX background_index
        LDA (@in), Y
        AND #$BF
        STA background, X
        ; background_index++
        INX
        ; inc_in()
        JSR @inc_in

        ; --------
        ; copy packet adr
        ; --------
        ; adr = ((@in[0] & $0F) << 8)
        LDA (@in), Y
        AND #$0F
        STA @adr_hi
        ; background[background_index] = (@in[0] & $0F) | PPU_NT_ADR
        ORA #>PPU_NAMETABLE_0
        STA background, X
        ; background_index++
        INX
        ; inc_in()
        JSR @inc_in
        ; adr |= MMC5_EXP_RAM
        LDA @adr_hi
        ORA #>MMC5_EXP_RAM
        STA @adr_hi
        ; adr |= @in[0]
        LDA (@in), Y
        STA @adr_lo
        ; background[background_index] = @in[0]
        STA background, X
        ; background_index++
        INX
        ; inc_in()
        JSR @inc_in

        ; --------
        ; copy packet data
        ; --------
        ; wait in_frame
        @wait_inframe:
            BIT scanline
            BVC @wait_inframe
        ; for size
        @for:
            ; --------
            ; copy low tile
            ; background[background_index] = @in[0]
            LDA (@in), Y
            STA background, X
            ; background_index++
            INX
            ; inc_in()
            JSR @inc_in
            ; --------
            ; copy high tile
            ; if not dont_draw_mmc5
            LDA @dont_draw_mmc5
            BNE :+++
                ; mmc5_tiles[adr] = @in[0]
                LDA (@in), Y
                STA (@adr), Y
                ; if v
                LDA @v
                BEQ :+
                    ; adr += 32
                    add_A2ptr @adr, #32
                    JMP :++
                ; else
                :
                    ; adr++
                    inc_16 @adr
                :
            :
            ; inc_in()
            JSR @inc_in
            ; continue
            DEC @i
            BNE @for
        ; zp_bkg_size -= size+3
        LDA @zp_bkg_size
        sub @size
        sub #$03
        STA @zp_bkg_size
        ; size = (size * 2) + 3
        LDA @size
        ASL
        add #$03
        STA @size
        ; background_index = X
        STX background_index
        LDA #$00
        STA background, X
        ; jmp @continue_noadd
        JMP @continue_noadd

        ; --------
        ; continue
        ; --------
        @continue:
        ; size = (size * 2) + 3
        LDA @size
        ASL
        add #$03
        STA @size
        ; @in += size
        add @in+0
        STA @in+0
        BCC :+
            JSR @inc_in_overflow
        :
        @continue_noadd:
        ; if can_move_read
        LDA @can_move_read
        BEQ :+
            ; packet_buf_read_adr += size
            LDA @size
            add_A2ptr packet_buf_read_adr
            LDA packet_buf_read_adr+1
            AND #>(PACKET_BUFFER_ADR+$3FF)
            STA packet_buf_read_adr+1
        :
        ; jmp @while
        JMP @while

    ; return
    @return:
    RTS


    @inc_in:
        ; @in[0] = 0
        LDA #$00
        STA (@in), Y
    @inc_in_no_z:
        ; @in++
        INC @in+0
        BNE :+
    @inc_in_overflow:
            INC @in+1
            ; loop between $000 and $3FF
            LDA @in+1
            AND #>(PACKET_BUFFER_ADR+$3FF)
            STA @in+1
        :
        RTS
