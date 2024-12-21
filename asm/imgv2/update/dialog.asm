update_dialog:
    @adr = tmp+0
    @packet = tmp+2

    ; save tmps
    push tmp+0
    push tmp+1
    push tmp+2
    push tmp+3

    ; if dialog box off
    LDA effect_flags
    AND #EFFECT_FLAG_PAL_SPLIT
        ; return
        BEQ @ret

    ; adr = $2260
    mov @adr+0, #$60
    mov @adr+1, #$82 ; + high priority
    ; for 8 packets
    LDX #0
    @send_packet:
        ; reserve packet
        LDY #$20
        JSR packet_buf_res
        ; for Y from 0 to 20
        LDY #$03
        @send_data:
            ; packet[Y*2+3] = DB_ADR_LO[X]
            LDA DB_ADR_LO, X
            STA (@packet), Y
            INY
            ; packet[Y*2+1+3] = DB_ADR_LO[X]
            LDA DB_ADR_HI, X
            STA (@packet), Y
            ; X++
            INX
            ; Y++
            INY
            ; continue
            CPY #$20*2+3
            BNE @send_data
        ; close packet
        LDA #$20
        JSR close_packet_nodefrag
        ; adr += $20
        LDA #$20
        add_A2ptr @adr
        ; continue
        CPX #$00
        BNE @send_packet

    @ret:
    ; restore tmps
    pull tmp+3
    pull tmp+2
    pull tmp+1
    pull tmp+0

    ; return
    RTS
