update_db:
    LDA #24
    STA update_image_arg+3
    LDA #16
    STA update_image_arg+1
    JMP update_all_no_hy

update_img_no_db:
    LDA #16
    STA update_image_arg+3
    JMP update_all_no_h

update_all:
    LDA #24
    STA update_image_arg+3
update_all_no_h:
    LDA #0
    STA update_image_arg+1
update_all_no_hy:
    LDA #0
    STA update_image_arg+0
    LDA #32
    STA update_image_arg+2
    ; update_image()
    LDY update_image_arg+1
    LDX update_image_arg+3
    JMP update_image


; RAM bank should be set before calling
; update_image:
    ; ----------------
    ; arguments
    ; ----------------
    @arg_x = update_image_arg+0
    @arg_y = update_image_arg+1
    @arg_w = update_image_arg+2
    @arg_h = update_image_arg+3

    ; ----------------
    ; variables
    ; ----------------
    @adr = tmp+0
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
    @old_buf_lo = tmp+18
    @old_buf_hi = tmp+20
    @size = tmp+22
    @max_size = tmp+23

    ; enable NMI_FORCE flag
    ; ora_adr nmi_flags, #NMI_FORCE

    ; size = 0
    LDY #$00
    STY @size

    ; ----------------
    ; compute start address
    ; ----------------
    ; adr = y*32+x
    LDA @arg_y
    STA MMC5_MUL_A
    LDA #$20
    STA MMC5_MUL_B
    LDA MMC5_MUL_A
    STA @adr+0
    LDA MMC5_MUL_B
    STA @adr+1
    add_A2ptr @adr, @arg_x

    ; ----------------
    ; init buffer pointers
    ; ----------------
    LDA @adr+0
    STA @img_chr_lo+0
    STA @img_chr_hi+0
    STA @img_bkg_lo+0
    STA @img_bkg_hi+0
    STA @img_buf_lo+0
    STA @img_buf_hi+0
    LDA @adr+1
    ORA #>IMG_BKG_LO_ADR
    STA @img_bkg_lo+1
    CLC
    ADC #$03
    STA @img_bkg_hi+1
    ADC #$03
    STA @img_chr_lo+1
    ADC #$03
    STA @img_chr_hi+1
    ADC #$03
    STA @img_buf_lo+1
    ADC #$03
    STA @img_buf_hi+1
    ADC #$03
    STA @old_buf_lo+1
    ADC #$03
    STA @old_buf_hi+1

    ; ----------------
    ; init ppu pointer
    ; and change other pointers if needed
    ; ----------------
    ; if draw in other nametable
    LDA img_flag
    AND #IMG_FLAG_OTHERNT
    BEQ :+
        ; adr += $400
        LDA @adr+1
        add #$04
        STA @adr+1
        ; img_buf += $600
        LDA @img_buf_lo+1
        add #$06
        STA @img_buf_lo+1
        ADC #$03
        STA @img_buf_hi+1
        ; old_buf -= $600
        LDA @old_buf_lo+1
        sub #$06
        STA @old_buf_lo+1
        ADC #$02 ; add #3
        STA @old_buf_hi+1
    :
    ; adr += $60
    add_A2ptr @adr, #$60
    ; adr |= dont draw mmc5 flag
    ora_adr @adr+1, #$40

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
            ; if tile (without palette) == 0
            AND #$3F
            BNE :++
            LDA @tile_lo
            BNE :++
                ; if palette == 1
                LDA @tile_hi
                AND #$C0
                CMP #$40
                BNE :+
                    ; tile = *old_buf
                    LDA (@old_buf_lo), Y
                    STA @tile_lo
                    LDA (@old_buf_hi), Y
                    STA @tile_hi
                    JMP :++
                :
                ; tile = *img_bkg
                LDA (@img_bkg_lo), Y
                STA @tile_lo
                LDA (@img_bkg_hi), Y
                STA @tile_hi
            :
            ; if not img_flag.force
            BIT img_flag
            BMI :+
            ; and if tile == *img_buf
            LDA (@img_buf_hi), Y
            CMP @tile_hi
            BNE :+
            LDA (@img_buf_lo), Y
            CMP @tile_lo
            BNE :+
                @cut_packet:
                ; if size already zero
                LDA @size
                    ; continue
                    BEQ @continue_x
                ;
                JSR close_packet
                ; size = 0
                LDY #$00
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
                ; w - i
                TXA
                sub @arg_w
                EOR #$FF
                TAY
                INY
                STY @max_size
                ; packet_adr = packet_buf_res(w - i, adr)
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
            inc_16 @adr
            INC @img_bkg_lo+0
            BNE :+
                INC @img_bkg_lo+1
                INC @img_bkg_hi+1
                INC @img_chr_lo+1
                INC @img_chr_hi+1
                INC @img_buf_lo+1
                INC @img_buf_hi+1
                INC @old_buf_lo+1
                INC @old_buf_hi+1
            :
            INC @img_bkg_hi+0
            INC @img_chr_lo+0
            INC @img_chr_hi+0
            INC @img_buf_lo+0
            INC @img_buf_hi+0
            INC @old_buf_lo+0
            INC @old_buf_hi+0
            ; continue
            INX
            CPX @arg_w
            BEQ :+
            JMP @for_x
            :
        ; packet_adr[0] = size (if not already 0)
        LDY #$00
        LDA @size
        BEQ :+
            JSR close_packet
            ; size = 0
            LDY #$00
            STY @size
        :
        ; add 32-w to pointers
        LDA #$20
        sub @arg_w
        BEQ :++ ; skip pointers if we add 0
        ; add to @adr
        PHA
        add_A2ptr @adr
        ; add to other
        PLA
        add @img_bkg_lo+0
        STA @img_bkg_lo+0
        BCC :+
            INC @img_bkg_lo+1
            INC @img_bkg_hi+1
            INC @img_chr_lo+1
            INC @img_chr_hi+1
            INC @img_buf_lo+1
            INC @img_buf_hi+1
            INC @old_buf_lo+1
            INC @old_buf_hi+1
        :
        STA @img_bkg_hi+0
        STA @img_chr_lo+0
        STA @img_chr_hi+0
        STA @img_buf_lo+0
        STA @img_buf_hi+0
        STA @old_buf_lo+0
        STA @old_buf_hi+0
        :
        ; continue
        INC @arg_y
        LDA @arg_y
        CMP @arg_h
        BEQ :+
        JMP @for_y
        :

    ; disable NMI_FORCE flag
    ; and_adr nmi_flags, #($FF-NMI_FORCE)

    ; return
    RTS
