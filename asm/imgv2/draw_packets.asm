draw_packet:
    pushregs

    ; --------
    ; variables
    ; --------
    @in = tmp+0
    @adr_lo = tmp+2
    @adr_hi = tmp+3
    @adr = @adr_lo
    @cur_prio = tmp+4
    @zp_bkg_size = tmp+5
    @can_move_read = tmp+6
    @v = tmp+7
    @size = tmp+8
    @i = tmp+9

    ; --------
    ; init
    ; --------
    ; zp_bkg_size = ZP_BACKGROUND_SIZE - background_index
    LDA ZP_BACKGROUND_SIZE
    sub background_index
    STA @zp_bkg_size
    ; can_move_read = true
    STA @can_move_read
    ; in = packet_buf_read_adr
    LDA packet_buf_read_adr+0
    STA @in+0
    LDA packet_buf_read_adr+1
    STA @in+1

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
        LDY #$00
        LDA (@in), Y
        BNE :++
            ; @in++
            inc_16 @in
            ; if can_move_read
            LDA @can_move_read
            BEQ @search
                ; packet_buf_read_adr++
                INC packet_buf_read_adr+0
                BNE :+
                    LDA packet_buf_read_adr+1
                    add #$01
                    AND #PACKET_BUF_MASK
                    STA packet_buf_read_adr+1
                :
            ; jmp @search
            JMP @search
        :

        ; --------
        ; check packet
        ; --------
        ; v = @in[0] & $80
        LDA (@in), Y
        AND #$80
        STA @v
        ; size = @in[0] & $3F
        LDA (@in), Y
        AND #$3F
        STA @size
        ; if size > zp_bkg_size
        CMP @zp_bkg_size
            ; can_move_read = 0
            ; jmp @continue
            BEQ :+
            BCS @skip_packet
            :
        ; notready = @in[0] & $40
        LDA (@in), Y
        AND #$40
        ; if notready
            ; can_move_read = 0
            ; jmp @continue
            BNE @skip_packet
        ; prio = @in[1] & $F0
        INY
        LDA (@in), Y
        AND #$F0
        ; if prio != @cur_prio
        CMP @cur_prio
        BEQ :+
            @skip_packet:
            ; can_move_read = 0
            LDA #$00
            STA @can_move_read
            ; jmp @continue
            BEQ @continue
        :

        ; --------
        ; copy packet info
        ; --------
        ; background[background_index] = @in[0] & $BF ; remove notready flag
        DEY
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
        LDA @size
        STA @i
        @for:
            ; --------
            ; copy low tile
            ; background[background_index] = @in[0]
            LDA (@in), Y
            STA background, X
            ; background_index++
            INX
            ; zp_bkg_size--
            DEC @zp_bkg_size
            ; inc_in()
            JSR @inc_in
            ; --------
            ; copy high tile
            ; mmc5_tiles[adr] = @in[0]
            TYA
            PHA
            LDA (@in), Y
            LDY #$00
            STA (@adr), Y
            PLA
            TAY
            ; if v
            LDA @v
            BEQ :+
                ; adr += 32
                add_A2ptr @adr, #20
                JMP :++
            ; else
            :
                ; adr++
                inc_16 @adr
            :
            ; inc_in()
            JSR @inc_in
            ; continue
            DEC @i
            BNE @for
        ; size = (size * 2) + 3
        LDA @size
        ASL
        add #$03
        STA @size
        ; in += y
        TYA
        ; jmp @continue_y
        JMP @continue_y

        ; --------
        ; continue
        ; --------
        @continue:
        ; size = (size * 2) + 3
        LDA @size
        ASL
        add #$03
        STA @size
        @continue_y:
        ; @in += size
        add_A2ptr @in
        ; if can_move_read
        LDA @can_move_read
        BEQ :+
            ; packet_buf_read_adr += size
            LDA @size
            add_A2ptr packet_buf_read_adr
            LDA packet_buf_read_adr+1
            AND #PACKET_BUF_MASK
            STA packet_buf_read_adr+1
        :
        ; jmp @while
        JMP @while

    ; return
    @return:
    pullregs
    RTS


    @inc_in:
        ; @in[0] = 0
        LDA #$00
        STA (@in), Y
        ; @in++
        INY
        RTS
