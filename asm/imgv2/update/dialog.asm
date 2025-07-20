update_dialog:
    @adr = tmp+0
    @packet = tmp+2
    @data_hi = tmp+4
    @data_lo = tmp+6
    @count = tmp+8

    ; save tmps
    push tmp+0
    push tmp+1
    push tmp+2
    push tmp+3
    push tmp+4
    push tmp+5
    push tmp+6
    push tmp+7
    push tmp+8

    ; set busy flag
    ora_adr txt_flags, #TXT_FLAG_BUSY

    ; adr = $2260
    mov @adr+0, #$60
    mov @adr+1, #$82 ; + high priority
    ; data_lo.l = 0
    ; data_hi.l = 0
    LDA #$00
    STA @data_lo+0
    STA @data_hi+0
    ; if dialog box off
    LDA effect_flags
    AND #EFFECT_FLAG_DIALOG
    BNE :+
        ; if image is displayed on the 1st buffer
        LDA img_flag
        AND #IMG_FLAG_OTHERNT
        BEQ @other_nt ; inverted but is in fact correct ?
            ; update 2nd buffer, then the 1st buffer
            ; (MMC5 upper tiles will be of the last updated buffer)
            ; adr = $2660
            mov @adr+1, #$86 ; + high priority
            ; data = bottom of image of 2nd buffer
            mov @data_hi+1, #>(IMG_BUF2_HI_ADR+$200)
            mov @data_lo+1, #>(IMG_BUF2_LO_ADR+$200)
            JSR send_box_update
            ; adr = $2260
            mov @adr+1, #$82 ; + high priority
            ; data = bottom of image of 1st buffer
            mov @data_hi+1, #>(IMG_BUF_HI_ADR+$200)
            mov @data_lo+1, #>(IMG_BUF_LO_ADR+$200)
            JSR send_box_update
            ;
            JMP :++
        ; else
        @other_nt:
            ; update 1st buffer, then the 2nd buffer
            ; (MMC5 upper tiles will be of the last updated buffer)
            ; adr = $2260
            mov @adr+1, #$82 ; + high priority
            ; data = bottom of image of 1st buffer
            mov @data_hi+1, #>(IMG_BUF_HI_ADR+$200)
            mov @data_lo+1, #>(IMG_BUF_LO_ADR+$200)
            JSR send_box_update
            ; adr = $2660
            mov @adr+1, #$86 ; + high priority
            ; data = bottom of image of 2nd buffer
            mov @data_hi+1, #>(IMG_BUF2_HI_ADR+$200)
            mov @data_lo+1, #>(IMG_BUF2_LO_ADR+$200)
            JSR send_box_update
            ;
            JMP :++
    ; else
    :
        ; data = dialog box
        mov @data_hi+1, #>DB_ADR_HI
        mov @data_lo+1, #>DB_ADR_LO
        JSR send_box_update
    :

    @ret:
    ; clear busy flag
    and_adr txt_flags, #($FF-TXT_FLAG_BUSY)
    ; restore tmps
    pull tmp+8
    pull tmp+7
    pull tmp+6
    pull tmp+5
    pull tmp+4
    pull tmp+3
    pull tmp+2
    pull tmp+1
    pull tmp+0
    ; return
    RTS


update_midbox:
    @adr = tmp+0
    @packet = tmp+2
    @data_hi = tmp+4
    @data_lo = tmp+6
    @count = tmp+8

    ; save tmps
    push tmp+0
    push tmp+1
    push tmp+2
    push tmp+3
    push tmp+4
    push tmp+5
    push tmp+6
    push tmp+7
    push tmp+8

    ; set busy flag
    ora_adr txt_flags, #TXT_FLAG_BUSY
    ; adr = $20E0
    mov @adr+0, #$E0
    mov @adr+1, #$00
    ; set banks
    LDA #IMG_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    LDA #GENERAL_BNK
    STA mmc5_banks+2
    STA MMC5_PRG_BNK1
    ; if midbox is enable
    LDA effect_flags
    AND #EFFECT_FLAG_MIDBOX
    BEQ :+
        ; data = midbox
        mov @data_hi+1, #>(DB_ADR_HI+$4000)
        mov @data_lo+1, #>(DB_ADR_LO+$4000)
        LDA #$00
        STA @data_lo+0
        STA @data_hi+0
        ; send data
        JSR send_box_update
        JMP :++
    ; else
    :
        ; data = middle of image of 1st buffer
        mov @data_hi+1, #>(IMG_BUF_HI_ADR+$80)
        mov @data_lo+1, #>(IMG_BUF_LO_ADR+$80)
        mov @data_hi+0, #<(IMG_BUF_HI_ADR+$80)
        mov @data_lo+0, #<(IMG_BUF_LO_ADR+$80)
        JSR send_box_update
        ; adr = $24E0
        mov @adr+1, #$84 ; + high priority
        ; data = middle of image of 2nd buffer
        mov @data_hi+1, #>(IMG_BUF2_HI_ADR+$80)
        mov @data_lo+1, #>(IMG_BUF2_LO_ADR+$80)
        mov @data_hi+0, #<(IMG_BUF2_HI_ADR+$80)
        mov @data_lo+0, #<(IMG_BUF2_LO_ADR+$80)
        JSR send_box_update
    :

    ; clear busy flag
    and_adr txt_flags, #($FF-TXT_FLAG_BUSY)
    ; restore tmps
    pull tmp+8
    pull tmp+7
    pull tmp+6
    pull tmp+5
    pull tmp+4
    pull tmp+3
    pull tmp+2
    pull tmp+1
    pull tmp+0
    ; return
    RTS


send_box_update:
    @adr = tmp+0
    @packet = tmp+2
    @data_hi = tmp+4
    @data_lo = tmp+6
    @count = tmp+8

    ; for 8 packets
    mov @count, #$08
send_box_update_n:
    @adr = tmp+0
    @packet = tmp+2
    @data_hi = tmp+4
    @data_lo = tmp+6
    @count = tmp+8

    LDX #0
    @send_packet:
        ; reserve packet
        LDY #$20
        JSR packet_buf_res
        ; for Y from $00 to $20
        LDY #$03
        @send_data:
            ; packet[Y*2+3+0] = *data_lo
            LDA (@data_lo, X)
            STA (@packet), Y
            INY
            ; packet[Y*2+3+1] = *data_hi
            LDA (@data_hi, X)
            STA (@packet), Y
            ; data_lo++
            inc_16 @data_lo
            ; data_hi++
            inc_16 @data_hi
            ; Y++
            INY
            ; continue
            CPY #$20*2+3
            BNE @send_data
        ; close packet
        LDA #$20
        JSR close_packet_nodefrag
        ; adr += $20
        add_A2ptr @adr
        ; continue
        DEC @count
        BNE @send_packet
    ; return
    RTS
