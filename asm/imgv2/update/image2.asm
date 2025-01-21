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


; args: Y=y, X=h
update_image:
    TYA
    PHA
    TXA
    PHA
    ; set image buffer bank
    LDA #IMG_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; update_image_buffer()
    JSR update_image_buffer
    ; send_image_buffer(y, h)
    PLA
    TAX
    PLA
    TAY
    JSR send_image_buffer
    ; return
    RTS

;
update_image_buffer:
    @tile_lo = tmp+0
    @tile_hi = tmp+1

    .macro update_image_buffer_page OFFSET, BUF1_LO, BUF1_HI, BUF2_LO, BUF2_HI
        ; tile = *img_chr (low)
        LDA IMG_CHR_LO_ADR+OFFSET, Y
        STA @tile_lo
        ; *img_change = true
        LDA #$FF
        STA IMG_CHANGE_ADR+OFFSET, Y
        ; tile = *img_chr (high)
        LDA IMG_CHR_HI_ADR+OFFSET, Y
        STA @tile_hi
        ; if tile (without palette) == 0
        AND #$3F
        BNE :+++
        LDA @tile_lo
        BNE :+++
            ; if palette == 1
            LDA @tile_hi
            AND #$C0
            CMP #$40
            BNE :+
                ; tile = *old_buf
                LDA BUF2_LO+OFFSET, Y
                STA @tile_lo
                LDA BUF2_HI+OFFSET, Y
                STA @tile_hi
                JMP :++
            :
            ; else
                ; tile = *img_bkg
                LDA IMG_BKG_LO_ADR+OFFSET, Y
                STA @tile_lo
                LDA IMG_BKG_HI_ADR+OFFSET, Y
                STA @tile_hi
            :
            ; if current_tile == tile
            CMP BUF1_HI+OFFSET, Y
            BNE :+
            LDA @tile_lo
            CMP BUF1_LO+OFFSET, Y
            BNE :+
                ; *img_change = false
                LDA #$00
                STA IMG_CHANGE_ADR+OFFSET, Y
        :
        ; *img_buf = tile
        LDA @tile_lo
        STA BUF1_LO+OFFSET, Y
        LDA @tile_hi
        STA BUF1_HI+OFFSET, Y
    .endmacro

    LDY #$00
    LDA img_flag
    AND #IMG_FLAG_OTHERNT
    BEQ @for1
    JMP @for2

    ; for 0 to 256
    @for1:
        ; page_1()
        update_image_buffer_page $000, IMG_BUF_LO_ADR, IMG_BUF_HI_ADR, IMG_BUF2_LO_ADR, IMG_BUF2_HI_ADR
        ; page_2()
        update_image_buffer_page $100, IMG_BUF_LO_ADR, IMG_BUF_HI_ADR, IMG_BUF2_LO_ADR, IMG_BUF2_HI_ADR
        ; page_3()
        update_image_buffer_page $200, IMG_BUF_LO_ADR, IMG_BUF_HI_ADR, IMG_BUF2_LO_ADR, IMG_BUF2_HI_ADR
        ; continue
        INY
        BEQ @for1_end
        JMP @for1
    @for1_end:
    ; return
    RTS

    ; for 0 to 256
    @for2:
        ; page_1()
        update_image_buffer_page $000, IMG_BUF2_LO_ADR, IMG_BUF2_HI_ADR, IMG_BUF_LO_ADR, IMG_BUF_HI_ADR
        ; page_2()
        update_image_buffer_page $100, IMG_BUF2_LO_ADR, IMG_BUF2_HI_ADR, IMG_BUF_LO_ADR, IMG_BUF_HI_ADR
        ; page_3()
        update_image_buffer_page $200, IMG_BUF2_LO_ADR, IMG_BUF2_HI_ADR, IMG_BUF_LO_ADR, IMG_BUF_HI_ADR
        ; continue
        INY
        BEQ @for2_end
        JMP @for2
    @for2_end:
    ; return
    RTS


; arg, Y=y, X=h
send_image_buffer:
    @adr = tmp+0
    @packet = tmp+2
    @n = tmp+4
    @i = tmp+6
    @new_img = tmp+8
    @change_img = tmp+10
    @size = tmp+12

    ; adr = y*32
    STY MMC5_MUL_A
    LDA #$20
    STA MMC5_MUL_B
    LDA MMC5_MUL_A
    STA @adr+0
    LDA MMC5_MUL_B
    STA @adr+1
    ; setup new_img &change_img pointers
    LDA @adr+0
    STA @new_img+0
    STA @change_img+0
    LDA img_flag
    AND #IMG_FLAG_OTHERNT
    BNE :+
        LDA #>IMG_BUF_LO_ADR
        BNE :++
    :
        LDA #>IMG_BUF2_LO_ADR
    :
    add @adr+1
    STA @new_img+1
    LDA @adr+1
    add #>IMG_CHANGE_ADR
    STA @change_img+1
    ; adr += current ppu nametable
    add_A2ptr @adr, #$60
    LDA @adr+1
    add #$20
    STA @adr+1
    LDA img_flag
    AND #IMG_FLAG_OTHERNT
    ORA @adr+1
    ; adr |= dont draw mmc5 flag
    ORA #$40
    STA @adr+1

    ; i = 0
    LDA #$00
    STA @i+0
    STA @i+1
    ; n = (h-y)*32
    TXA
    STY @n+0
    sub @n+0
    STA @n+0
    shift LSR, 3
    STA @n+1
    LDA @n+0
    shift ASL, 5
    STA @n+0
    ; while i < n
    LDY #$00
    @while:
        LDA @i+1
        CMP @n+1
        blt :+
        LDA @i+0
        CMP @n+0
        blt :+
        JMP @while_end
        :
        ; if change
        LDA (@change_img), Y
        BEQ @else
            ; size = 0
            ; while change && size < 32 && i < n
            @loop:
                ; change
                LDA (@change_img), Y
                BEQ @loop_end
                ; size < 32
                CPY #32
                bge @loop_end
                ; save tile
                LDA (@new_img), Y
                STA img_tmp_buf, Y
                ; i < n
                LDA @i+1
                CMP @n+1
                blt :+
                LDA @i+0
                CMP @n+0
                bge @loop_end
                :
                ; size++
                INY
                ; i++
                inc_16 @i
                ; continue
                JMP @loop
            @loop_end:
            STY @size
            ; open packet at cur adr (no mmc5)
            JSR packet_buf_res
            ; add tiles
            LDA @size
            ASL
            add #$01
            TAY
            LDX @size
            @send:
                LDA img_tmp_buf-1, X
                STA (@packet), Y
                ; continue
                DEY
                DEY
                DEX
                BNE @send
            ; close packet
            LDA @size
            JSR close_packet_nodefrag
            ; img_ptr += size
            add_A2ptr @new_img, @size
            add_A2ptr @change_img, @size
            add_A2ptr @adr, @size
            ; continue
            JMP @while
        ; else
        @else:
            ; img_ptr++
            inc_16 @new_img
            inc_16 @change_img
            inc_16 @adr
            ; i++
            inc_16 @i
            ; continue
            JMP @while
    @while_end:

    ; return
    RTS
