update_image:
    @arg_x = update_image_arg+0
    @arg_y = update_image_arg+1
    @arg_w = update_image_arg+2
    @arg_h = update_image_arg+3

    @adr = tmp+0
    @adr_lo = @adr+0
    @adr_hi = @adr+1
    @packet_adr = tmp+2
    @tile = tmp+4
    @tile_lo = @tile+0
    @tile_hi = @tile+1
    @img_bkg_lo = tmp+6
    @img_bkg_hi = tmp+8
    @img_chr_lo = tmp+10
    @img_chr_hi = tmp+12
    @img_buf_lo = tmp+14
    @img_buf_hi = tmp+16
    @size = tmp+18

    ; size = 0
    LDA #$00
    STA @size

    ; adr = y*32+x
    LDA @arg_y
    STA MMC5_MUL_A
    LDA #$20
    STA MMC5_MUL_B
    LDA MMC5_MUL_A
    STA @adr_lo
    LDA MMC5_MUL_B
    STA @adr_hi
    add_A2ptr @adr, @arg_x
    ; init pointers
    LDA @adr_lo
    STA @img_chr_lo+0
    STA @img_chr_hi+0
    STA @img_bkg_lo+0
    STA @img_bkg_hi+0
    STA @img_buf_lo+0
    STA @img_buf_hi+0
    LDA @adr_hi
    ORA #64
    STA @img_bkg_lo+1
    CLC
    ADC #$04
    STA @img_bkg_hi+1
    ADC #$04
    STA @img_chr_lo+1
    ADC #$04
    STA @img_chr_hi+1
    ADC #$04
    STA @img_buf_lo+1
    ADC #$04
    STA @img_buf_hi+1

    ; for j from y to h
    @for_y:
        ; for i from x to w
        LDX @arg_x
        @for_x:
            LDY #$00
            ; tile = *img_chr
            LDA (@img_chr_lo), Y
            STA @tile_lo
            LDA (@img_chr_hi), Y
            STA @tile_hi
            ; if tile == 0
            BNE :+
            LDA @tile_lo
            BNE :+
                ; tile = *img_bkg
                LDA (@img_bkg_lo), Y
                STA @tile_lo
                LDA (@img_bkg_hi), Y
                STA @tile_hi
            :
            ; if tile == *img_buf
            LDA (@img_buf_hi), Y
            CMP @tile_hi
            BNE :+
            LDA (@img_buf_lo), Y
            CMP @tile_lo
            BNE :+
                ; packet_adr[0] = size
                LDA @size
                STA (@packet_adr), Y
                ; size = 0
                STY @size
                ; continue
                JMP @continue_x
            :

            ; *img_buf = tile
            LDA @tile_lo
            STA (@img_buf_lo), Y
            LDA @tile_hi
            STA (@img_buf_hi), Y
            ; if size == 0
            LDA @size
            BNE :+
                ; adr2ppu(adr)
                LDA @img_buf_hi
                AND #$03
                ORA #>PPU_NAMETABLE_0
                STA @adr_hi
                LDA @img_buf_lo
                STA @adr_lo
                ; w - i
                TXA
                sub @arg_w
                EOR #$FF
                add #$01
                ; packet_adr = packet_buf_res(w - i, adr2ppu(adr))
                LDA packet_buf_write_adr+0
                STA @packet_adr+0
                LDA packet_buf_write_adr+1
                STA @packet_adr+1
                JSR packet_buf_res
            :
            ; packet_adr[(size*2)+3] = tile
            LDA @size
            ASL
            add #$03
            TAY
            LDA @tile_lo
            STA (@packet_adr), Y
            INY
            LDA @tile_hi
            STA (@packet_adr), Y
            ; size++
            INC @size
            @continue_x:
            ; increase pointers
            INC @img_bkg_lo+0
            BNE :+
                INC @img_bkg_lo+1
                INC @img_bkg_hi+1
                INC @img_chr_lo+1
                INC @img_chr_hi+1
                INC @img_buf_lo+1
                INC @img_buf_hi+1
            :
            INC @img_bkg_hi+0
            INC @img_chr_lo+0
            INC @img_chr_hi+0
            INC @img_buf_lo+0
            INC @img_buf_hi+0
            ; continue
            INX
            CPX @arg_w
            BEQ :+
            JMP @for_y
            :
        ; packet_adr[0] = size
        LDY #$00
        LDA @size
        STA (@packet_adr), Y
        ; size = 0
        STY @size
        ; add w to pointers
        LDA @arg_w
        CLC
        ADC @img_bkg_lo+0
        BCC :+
            INC @img_bkg_lo+1
            INC @img_bkg_hi+1
            INC @img_chr_lo+1
            INC @img_chr_hi+1
            INC @img_buf_lo+1
            INC @img_buf_hi+1
        :
        STA @img_bkg_hi+0
        STA @img_chr_lo+0
        STA @img_chr_hi+0
        STA @img_buf_lo+0
        STA @img_buf_hi+0
        ; continue
        INC @arg_y
        LDA @arg_y
        CMP @arg_h
        BEQ :+
        JMP @for_y
        :
    ; return
    RTS