update_dialog:
    @adr = tmp+0
    @packet = tmp+2

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
        LDY #$00
        LDA #$20
        STA (@packet), Y
        ; adr += $40
        add_A2ptr @adr
        ; continue
        CPX #$00
        BNE @send_packet
    ; return
    RTS
