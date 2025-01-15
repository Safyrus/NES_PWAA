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
    AND #EFFECT_FLAG_PAL_SPLIT
    BNE :+
        ; data = bottom of image of 1st buffer
        mov @data_hi+1, #>(IMG_BUF_HI_ADR+$200)
        mov @data_lo+1, #>(IMG_BUF_LO_ADR+$200)
        JSR @main
        ; adr = $2660
        mov @adr+1, #$86 ; + high priority
        ; data = bottom of image of 2nd buffer
        mov @data_hi+1, #>(IMG_BUF2_HI_ADR+$200)
        mov @data_lo+1, #>(IMG_BUF2_LO_ADR+$200)
        JSR @main
        JMP @ret
    ; else
    :
        ; data = dialog box
        mov @data_hi+1, #>DB_ADR_HI
        mov @data_lo+1, #>DB_ADR_LO
        JSR @main
        JMP @ret


    @main:
    ; for 8 packets
    LDX #0
    mov @count, #$08
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
    RTS

    @ret:
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
